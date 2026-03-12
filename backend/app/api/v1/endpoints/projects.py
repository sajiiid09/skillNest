from __future__ import annotations

from typing import Optional

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user, require_role
from app.models.user import User
from app.schemas.project import ProjectCreate, ProjectRead
from app.schemas.task import TaskRead
from app.services.project_service import create_project, list_projects
from app.services.task_service import list_project_tasks, verify_project_owner


router = APIRouter()


@router.get("", response_model=list[ProjectRead])
def get_projects(
    search: Optional[str] = None,
    tags: Optional[str] = None,
    min_rate: Optional[float] = None,
    max_rate: Optional[float] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[ProjectRead]:
    return list_projects(
        db,
        current_user,
        search=search,
        tags=tags,
        min_rate=min_rate,
        max_rate=max_rate,
    )


@router.post("/", response_model=ProjectRead, status_code=status.HTTP_201_CREATED)
def post_project(
    payload: ProjectCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("buyer")),
) -> ProjectRead:
    return create_project(db, current_user, payload)


@router.get("/{project_id}/tasks", response_model=list[TaskRead])
def get_project_tasks(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[TaskRead]:
    verify_project_owner(db, project_id, current_user)
    tasks = list_project_tasks(db, project_id)
    return [
        TaskRead(
            id=task.id,
            project_id=task.project_id,
            title=task.title,
            description=task.description,
            hourly_rate=float(task.hourly_rate),
            estimated_hours=float(task.estimated_hours),
            time_spent=float(task.time_spent),
            status=task.status.value,
            solution_file_path=task.solution_file_path,
            submitted_at=task.submitted_at,
            created_at=task.created_at,
        )
        for task in tasks
    ]
