from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class ProposalCreate(BaseModel):
    project_id: int
    cover_letter: str = Field(min_length=1)
    proposed_hourly_rate: float = Field(gt=0)
    estimated_hours: float = Field(gt=0)


class ProposalRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    project_id: int
    cover_letter: str
    proposed_hourly_rate: float
    estimated_hours: float
    status: str
    developer_name: Optional[str] = None
    developer_email: Optional[str] = None
    created_at: datetime
