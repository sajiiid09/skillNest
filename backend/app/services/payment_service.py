from __future__ import annotations

from decimal import Decimal, ROUND_HALF_UP
from typing import Union

import stripe
from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.payment import Payment, PaymentProvider, PaymentStatus
from app.models.task import Task, TaskStatus


def _to_cents(amount: Decimal) -> int:
    cents = (amount * Decimal("100")).quantize(Decimal("1"), rounding=ROUND_HALF_UP)
    return int(cents)


def pay_task(db: Session, task: Task) -> Payment:
    if task.status != TaskStatus.SUBMITTED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only submitted tasks can be paid",
        )

    existing_payment = db.scalar(select(Payment).where(Payment.task_id == task.id))
    if existing_payment is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Task has already been paid",
        )

    settings = get_settings()
    if not settings.stripe_secret_key:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Stripe is not configured",
        )

    stripe.api_key = settings.stripe_secret_key

    amount = Decimal(str(task.time_spent)) * Decimal(str(task.hourly_rate))
    if amount <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Task amount must be greater than zero before payment",
        )

    try:
        intent = stripe.PaymentIntent.create(
            amount=_to_cents(amount),
            currency=settings.stripe_currency,
            payment_method=settings.stripe_test_payment_method,
            confirm=True,
            automatic_payment_methods={"enabled": False},
            metadata={"task_id": str(task.id)},
        )
    except stripe.error.StripeError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc.user_message or "Payment could not be processed"),
        ) from exc

    payment = Payment(
        task_id=task.id,
        buyer_id=task.buyer_id,
        developer_id=task.developer_id,
        amount=float(amount),
        currency=settings.stripe_currency,
        provider=PaymentProvider.STRIPE_TEST,
        provider_payment_id=intent["id"],
        status=PaymentStatus.PAID,
    )
    task.status = TaskStatus.PAID

    db.add(payment)
    db.add(task)
    db.commit()
    db.refresh(payment)
    return payment


def get_admin_dashboard_stats(db: Session) -> dict[str, Union[float, int]]:
    from app.models.project import Project
    from app.models.user import User, UserRole

    total_buyers = db.scalar(
        select(func.count(User.id)).where(User.role == UserRole.BUYER)
    ) or 0
    total_developers = db.scalar(
        select(func.count(User.id)).where(User.role == UserRole.DEVELOPER)
    ) or 0
    total_projects = db.scalar(select(func.count(Project.id))) or 0
    total_tasks = db.scalar(select(func.count(Task.id))) or 0
    tasks_in_progress = db.scalar(
        select(func.count(Task.id)).where(Task.status == TaskStatus.IN_PROGRESS)
    ) or 0
    tasks_submitted = db.scalar(
        select(func.count(Task.id)).where(Task.status == TaskStatus.SUBMITTED)
    ) or 0
    tasks_completed = db.scalar(
        select(func.count(Task.id)).where(Task.status == TaskStatus.PAID)
    ) or 0
    total_revenue = db.scalar(select(func.coalesce(func.sum(Payment.amount), 0))) or 0

    return {
        "total_buyers": total_buyers,
        "total_developers": total_developers,
        "total_projects": total_projects,
        "total_tasks": total_tasks,
        "tasks_todo": 0,
        "tasks_in_progress": tasks_in_progress,
        "tasks_submitted": tasks_submitted,
        "tasks_completed": tasks_completed,
        "total_revenue": float(total_revenue),
    }
