from __future__ import annotations

from datetime import datetime
from enum import Enum
from typing import Optional

from sqlalchemy import DateTime, Enum as SqlEnum, ForeignKey, Numeric, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class TaskStatus(str, Enum):
    IN_PROGRESS = "in_progress"
    SUBMITTED = "submitted"
    PAID = "paid"


class Task(Base):
    __tablename__ = "tasks"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    project_id: Mapped[int] = mapped_column(ForeignKey("projects.id"), nullable=False, index=True)
    developer_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    buyer_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    hourly_rate: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    estimated_hours: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    time_spent: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False, default=0, server_default="0")
    status: Mapped[TaskStatus] = mapped_column(
        SqlEnum(TaskStatus, name="task_status", native_enum=False),
        nullable=False,
        default=TaskStatus.IN_PROGRESS,
        server_default=TaskStatus.IN_PROGRESS.value,
    )
    solution_file_path: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    submitted_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )

    project = relationship("Project", back_populates="tasks")
    developer = relationship("User", back_populates="developer_tasks", foreign_keys=[developer_id])
    buyer = relationship("User", back_populates="buyer_tasks", foreign_keys=[buyer_id])
    payments = relationship("Payment", back_populates="task", cascade="all, delete-orphan")
