from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user, require_role
from app.models.proposal import Proposal
from app.models.task import TaskStatus
from app.models.user import User
from app.schemas.task import TaskRead, TaskStatusUpdate
from app.services.proposal_service import create_task_from_proposal
from app.services.task_service import (
    get_task_or_404,
    list_my_tasks,
    list_project_tasks,
    resolve_download_path,
    submit_task,
    update_task_status,
    verify_project_owner,
)


router = APIRouter()


def _serialize_task(task) -> TaskRead:
    return TaskRead(
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


def _ensure_task_access(task, user: User) -> None:
    if user.role.value == "admin":
        return
    if user.role.value == "buyer" and task.buyer_id == user.id:
        return
    if user.role.value == "developer" and task.developer_id == user.id:
        return
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="You do not have permission to access this task",
    )


@router.get("/", response_model=list[TaskRead])
def get_my_tasks(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("developer")),
) -> list[TaskRead]:
    return [_serialize_task(task) for task in list_my_tasks(db, current_user)]


@router.get("/{task_id}", response_model=TaskRead)
def get_task(
    task_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> TaskRead:
    task = get_task_or_404(db, task_id)
    _ensure_task_access(task, current_user)
    return _serialize_task(task)


@router.put("/{task_id}", response_model=TaskRead)
def put_task(
    task_id: int,
    payload: TaskStatusUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("developer")),
) -> TaskRead:
    task = get_task_or_404(db, task_id)
    _ensure_task_access(task, current_user)
    updated_task = update_task_status(db, task, payload)
    return _serialize_task(updated_task)


@router.post("/proposal/{proposal_id}/accept-and-create-task", response_model=TaskRead)
def accept_proposal_and_create_task(
    proposal_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> TaskRead:
    proposal = db.get(Proposal, proposal_id)
    if proposal is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Proposal not found")

    verify_project_owner(db, proposal.project_id, current_user)
    task = create_task_from_proposal(db, proposal)
    return _serialize_task(task)


@router.post("/{task_id}/submit", response_model=TaskRead)
def post_submit_task(
    task_id: int,
    time_spent: float = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("developer")),
) -> TaskRead:
    task = get_task_or_404(db, task_id)
    _ensure_task_access(task, current_user)
    updated_task = submit_task(db, task, time_spent, file)
    return _serialize_task(updated_task)


@router.get("/{task_id}/download")
def download_task_file(
    task_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> FileResponse:
    task = get_task_or_404(db, task_id)
    if current_user.role.value not in {"buyer", "admin"}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only buyers and admins can download task files",
        )
    _ensure_task_access(task, current_user)
    file_path = resolve_download_path(task)
    return FileResponse(file_path, filename=file_path.name)
