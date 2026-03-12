from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class ProjectCreate(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    description: str = Field(min_length=1)
    expected_hourly_rate: float = Field(gt=0)
    expected_duration_hours: float = Field(gt=0)
    tags: list[str] = Field(default_factory=list)


class ProjectRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    description: str
    expected_hourly_rate: float
    expected_duration_hours: float
    tags: list[str]
    is_open: bool
    created_at: datetime
