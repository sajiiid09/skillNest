from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy import select

from app.core.config import get_settings
from app.core.database import SessionLocal
from app.core.security import hash_password
from app.models.payment import Payment, PaymentProvider, PaymentStatus
from app.models.project import Project
from app.models.proposal import Proposal, ProposalStatus
from app.models.task import Task, TaskStatus
from app.models.user import User, UserRole

SEED_PASSWORD = "user@123"


BUYER_USERS = [
    {"email": "buyer1@example.com", "full_name": "Ariana Buyer", "role": UserRole.BUYER},
    {"email": "buyer2@example.com", "full_name": "Morgan Buyer", "role": UserRole.BUYER},
]

DEVELOPER_USERS = [
    {"email": "dev1@example.com", "full_name": "Riley Developer", "role": UserRole.DEVELOPER},
    {"email": "dev2@example.com", "full_name": "Jordan Developer", "role": UserRole.DEVELOPER},
]


def upsert_user(db, *, email: str, full_name: str, role: UserRole, password_hash: str) -> User:
    user = db.scalar(select(User).where(User.email == email))
    if user is None:
        user = User(
            email=email,
            full_name=full_name,
            role=role,
            password_hash=password_hash,
        )
        db.add(user)
        db.flush()
        return user

    user.full_name = full_name
    user.role = role
    user.password_hash = password_hash
    db.add(user)
    db.flush()
    return user


def get_or_create_project(
    db,
    *,
    buyer_id: int,
    title: str,
    description: str,
    expected_hourly_rate: float,
    expected_duration_hours: float,
    tags: list[str],
    is_open: bool,
) -> Project:
    project = db.scalar(
        select(Project).where(Project.buyer_id == buyer_id, Project.title == title)
    )
    if project is None:
        project = Project(
            buyer_id=buyer_id,
            title=title,
            description=description,
            expected_hourly_rate=expected_hourly_rate,
            expected_duration_hours=expected_duration_hours,
            tags=tags,
            is_open=is_open,
        )
        db.add(project)
        db.flush()
        return project

    project.description = description
    project.expected_hourly_rate = expected_hourly_rate
    project.expected_duration_hours = expected_duration_hours
    project.tags = tags
    project.is_open = is_open
    db.add(project)
    db.flush()
    return project


def get_or_create_proposal(
    db,
    *,
    project_id: int,
    developer_id: int,
    cover_letter: str,
    proposed_hourly_rate: float,
    estimated_hours: float,
    status: ProposalStatus,
) -> Proposal:
    proposal = db.scalar(
        select(Proposal).where(
            Proposal.project_id == project_id,
            Proposal.developer_id == developer_id,
        )
    )
    if proposal is None:
        proposal = Proposal(
            project_id=project_id,
            developer_id=developer_id,
            cover_letter=cover_letter,
            proposed_hourly_rate=proposed_hourly_rate,
            estimated_hours=estimated_hours,
            status=status,
        )
        db.add(proposal)
        db.flush()
        return proposal

    proposal.cover_letter = cover_letter
    proposal.proposed_hourly_rate = proposed_hourly_rate
    proposal.estimated_hours = estimated_hours
    proposal.status = status
    db.add(proposal)
    db.flush()
    return proposal


def get_or_create_task(
    db,
    *,
    project_id: int,
    developer_id: int,
    buyer_id: int,
    title: str,
    description: str,
    hourly_rate: float,
    estimated_hours: float,
    time_spent: float,
    status: TaskStatus,
) -> Task:
    task = db.scalar(select(Task).where(Task.project_id == project_id))
    if task is None:
        task = Task(
            project_id=project_id,
            developer_id=developer_id,
            buyer_id=buyer_id,
            title=title,
            description=description,
            hourly_rate=hourly_rate,
            estimated_hours=estimated_hours,
            time_spent=time_spent,
            status=status,
            submitted_at=datetime.now(timezone.utc)
            if status in {TaskStatus.SUBMITTED, TaskStatus.PAID}
            else None,
        )
        db.add(task)
        db.flush()
        return task

    task.developer_id = developer_id
    task.buyer_id = buyer_id
    task.title = title
    task.description = description
    task.hourly_rate = hourly_rate
    task.estimated_hours = estimated_hours
    task.time_spent = time_spent
    task.status = status
    task.submitted_at = (
        datetime.now(timezone.utc) if status in {TaskStatus.SUBMITTED, TaskStatus.PAID} else None
    )
    db.add(task)
    db.flush()
    return task


def get_or_create_payment(
    db,
    *,
    task_id: int,
    buyer_id: int,
    developer_id: int,
    amount: float,
) -> Payment:
    payment = db.scalar(select(Payment).where(Payment.task_id == task_id))
    if payment is None:
        payment = Payment(
            task_id=task_id,
            buyer_id=buyer_id,
            developer_id=developer_id,
            amount=amount,
            currency="usd",
            provider=PaymentProvider.STRIPE_TEST,
            provider_payment_id=f"seed_payment_task_{task_id}",
            status=PaymentStatus.PAID,
            paid_at=datetime.now(timezone.utc),
        )
        db.add(payment)
        db.flush()
        return payment

    payment.buyer_id = buyer_id
    payment.developer_id = developer_id
    payment.amount = amount
    payment.currency = "usd"
    payment.provider = PaymentProvider.STRIPE_TEST
    payment.provider_payment_id = f"seed_payment_task_{task_id}"
    payment.status = PaymentStatus.PAID
    payment.paid_at = datetime.now(timezone.utc)
    db.add(payment)
    db.flush()
    return payment


def main() -> None:
    settings = get_settings()
    password_hash = hash_password(SEED_PASSWORD)

    with SessionLocal() as db:
        admin = upsert_user(
            db,
            email=settings.admin_email,
            full_name=settings.admin_full_name,
            role=UserRole.ADMIN,
            password_hash=password_hash,
        )

        buyers = [
            upsert_user(db, password_hash=password_hash, **buyer_payload)
            for buyer_payload in BUYER_USERS
        ]
        developers = [
            upsert_user(db, password_hash=password_hash, **developer_payload)
            for developer_payload in DEVELOPER_USERS
        ]

        projects_data = [
            {
                "buyer": buyers[0],
                "title": "E-commerce Checkout Revamp",
                "description": "Improve checkout UX, discount logic, and validation errors.",
                "expected_hourly_rate": 42.0,
                "expected_duration_hours": 36.0,
                "tags": ["python", "fastapi", "stripe"],
                "is_open": False,
            },
            {
                "buyer": buyers[0],
                "title": "Analytics Dashboard Export",
                "description": "Add CSV and PDF exports with role-aware filters.",
                "expected_hourly_rate": 38.0,
                "expected_duration_hours": 24.0,
                "tags": ["sql", "reporting", "api"],
                "is_open": False,
            },
            {
                "buyer": buyers[1],
                "title": "Notification Delivery Pipeline",
                "description": "Queue-based notification retry system and admin logs.",
                "expected_hourly_rate": 45.0,
                "expected_duration_hours": 30.0,
                "tags": ["background-jobs", "email", "observability"],
                "is_open": False,
            },
            {
                "buyer": buyers[1],
                "title": "Profile Settings Cleanup",
                "description": "Refine profile settings forms and validation messages.",
                "expected_hourly_rate": 32.0,
                "expected_duration_hours": 18.0,
                "tags": ["frontend", "validation", "ux"],
                "is_open": True,
            },
        ]

        projects: list[Project] = []
        for payload in projects_data:
            project = get_or_create_project(
                db,
                buyer_id=payload["buyer"].id,
                title=payload["title"],
                description=payload["description"],
                expected_hourly_rate=payload["expected_hourly_rate"],
                expected_duration_hours=payload["expected_duration_hours"],
                tags=payload["tags"],
                is_open=payload["is_open"],
            )
            projects.append(project)

        for index, project in enumerate(projects):
            for dev_index, developer in enumerate(developers):
                proposal_status = ProposalStatus.PENDING
                if not project.is_open:
                    proposal_status = (
                        ProposalStatus.ACCEPTED
                        if dev_index == index % len(developers)
                        else ProposalStatus.REJECTED
                    )

                get_or_create_proposal(
                    db,
                    project_id=project.id,
                    developer_id=developer.id,
                    cover_letter=(
                        "I can deliver this scope with clear milestones, testing, "
                        "and weekly demos."
                    ),
                    proposed_hourly_rate=project.expected_hourly_rate + (dev_index + 1),
                    estimated_hours=project.expected_duration_hours - 2,
                    status=proposal_status,
                )

        task_specs = [
            {
                "project": projects[0],
                "developer": developers[0],
                "status": TaskStatus.IN_PROGRESS,
                "time_spent": 6.5,
            },
            {
                "project": projects[1],
                "developer": developers[1],
                "status": TaskStatus.SUBMITTED,
                "time_spent": 12.0,
            },
            {
                "project": projects[2],
                "developer": developers[0],
                "status": TaskStatus.PAID,
                "time_spent": 20.0,
            },
        ]

        paid_task_count = 0
        for spec in task_specs:
            task = get_or_create_task(
                db,
                project_id=spec["project"].id,
                developer_id=spec["developer"].id,
                buyer_id=spec["project"].buyer_id,
                title=spec["project"].title,
                description=spec["project"].description,
                hourly_rate=spec["project"].expected_hourly_rate,
                estimated_hours=spec["project"].expected_duration_hours,
                time_spent=spec["time_spent"],
                status=spec["status"],
            )

            if task.status == TaskStatus.PAID:
                paid_task_count += 1
                get_or_create_payment(
                    db,
                    task_id=task.id,
                    buyer_id=task.buyer_id,
                    developer_id=task.developer_id,
                    amount=float(task.hourly_rate) * float(task.time_spent),
                )

        db.commit()

        print("Seeded dummy data successfully")
        print(f"Admin user: {admin.email}")
        print("Buyer users: " + ", ".join(user.email for user in buyers))
        print("Developer users: " + ", ".join(user.email for user in developers))
        print(f"Projects: {len(projects)}")
        print(f"Paid tasks: {paid_task_count}")
        print(f"Password for all seeded users: {SEED_PASSWORD}")


if __name__ == "__main__":
    main()
