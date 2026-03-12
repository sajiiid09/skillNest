from datetime import datetime, timezone
from pathlib import Path

from fastapi import HTTPException, UploadFile, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.project import Project
from app.models.task import Task, TaskStatus
from app.models.user import User
from app.schemas.task import TaskStatusUpdate
from app.services.file_service import save_task_file


def list_my_tasks(db: Session, user: User) -> list[Task]:
    query = select(Task).where(Task.developer_id == user.id).order_by(Task.created_at.desc())
    return list(db.scalars(query).all())


def list_project_tasks(db: Session, project_id: int) -> list[Task]:
    query = select(Task).where(Task.project_id == project_id).order_by(Task.created_at.desc())
    return list(db.scalars(query).all())


def get_task_or_404(db: Session, task_id: int) -> Task:
    task = db.get(Task, task_id)
    if task is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    return task


def submit_task(
    db: Session,
    task: Task,
    time_spent: float,
    upload: UploadFile,
) -> Task:
    if task.status == TaskStatus.PAID:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Paid tasks cannot be resubmitted",
        )

    file_path = save_task_file(task.id, upload)
    task.time_spent = time_spent
    task.solution_file_path = file_path
    task.status = TaskStatus.SUBMITTED
    task.submitted_at = datetime.now(timezone.utc)

    db.add(task)
    db.commit()
    db.refresh(task)
    return task


def update_task_status(db: Session, task: Task, payload: TaskStatusUpdate) -> Task:
    allowed_statuses = {TaskStatus.IN_PROGRESS.value, TaskStatus.SUBMITTED.value}
    if payload.status not in allowed_statuses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported task status",
        )

    if task.status == TaskStatus.PAID:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Paid tasks cannot be updated",
        )

    task.status = TaskStatus(payload.status)
    if task.status != TaskStatus.SUBMITTED:
        task.submitted_at = None

    db.add(task)
    db.commit()
    db.refresh(task)
    return task


def resolve_download_path(task: Task) -> Path:
    if task.status != TaskStatus.PAID or not task.solution_file_path:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Task file is not available for download",
        )

    file_path = Path(task.solution_file_path)
    if not file_path.exists():
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task file not found",
        )
    return file_path


def verify_project_owner(db: Session, project_id: int, user: User) -> Project:
    project = db.get(Project, project_id)
    if project is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project not found")

    if user.role.value != "admin" and project.buyer_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to access this project",
        )
    return project
