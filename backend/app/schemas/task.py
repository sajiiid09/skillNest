from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict


class TaskRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    project_id: int
    title: str
    description: str
    hourly_rate: float
    estimated_hours: float
    time_spent: float
    status: str
    solution_file_path: Optional[str] = None
    submitted_at: Optional[datetime] = None
    created_at: datetime


class TaskStatusUpdate(BaseModel):
    status: str
