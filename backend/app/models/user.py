from datetime import datetime
from enum import Enum

from sqlalchemy import DateTime, Enum as SqlEnum, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class UserRole(str, Enum):
    BUYER = "buyer"
    DEVELOPER = "developer"
    ADMIN = "admin"


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[UserRole] = mapped_column(
        SqlEnum(UserRole, name="user_role", native_enum=False),
        nullable=False,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )

    projects = relationship("Project", back_populates="buyer")
    proposals = relationship("Proposal", back_populates="developer")
    developer_tasks = relationship(
        "Task",
        back_populates="developer",
        foreign_keys="Task.developer_id",
    )
    buyer_tasks = relationship(
        "Task",
        back_populates="buyer",
        foreign_keys="Task.buyer_id",
    )
