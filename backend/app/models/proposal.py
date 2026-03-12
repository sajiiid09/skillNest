from datetime import datetime
from enum import Enum

from sqlalchemy import DateTime, Enum as SqlEnum, ForeignKey, Numeric, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class ProposalStatus(str, Enum):
    PENDING = "pending"
    ACCEPTED = "accepted"
    REJECTED = "rejected"


class Proposal(Base):
    __tablename__ = "proposals"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    project_id: Mapped[int] = mapped_column(ForeignKey("projects.id"), nullable=False, index=True)
    developer_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    cover_letter: Mapped[str] = mapped_column(Text, nullable=False)
    proposed_hourly_rate: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    estimated_hours: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    status: Mapped[ProposalStatus] = mapped_column(
        SqlEnum(ProposalStatus, name="proposal_status", native_enum=False),
        nullable=False,
        default=ProposalStatus.PENDING,
        server_default=ProposalStatus.PENDING.value,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )

    project = relationship("Project", back_populates="proposals")
    developer = relationship("User", back_populates="proposals")
