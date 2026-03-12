from __future__ import annotations

from typing import Optional

from sqlalchemy import Select, or_, select
from sqlalchemy.orm import Session

from app.models.project import Project
from app.models.user import User
from app.schemas.project import ProjectCreate


def _project_query_for_user(user: User) -> Select[tuple[Project]]:
    query = select(Project)
    if user.role.value == "buyer":
        query = query.where(Project.buyer_id == user.id)
    elif user.role.value == "developer":
        query = query.where(Project.is_open.is_(True))
    return query


def list_projects(
    db: Session,
    user: User,
    search: Optional[str] = None,
    tags: Optional[str] = None,
    min_rate: Optional[float] = None,
    max_rate: Optional[float] = None,
) -> list[Project]:
    query = _project_query_for_user(user)

    if search:
        pattern = f"%{search.strip()}%"
        query = query.where(
            or_(
                Project.title.ilike(pattern),
                Project.description.ilike(pattern),
            )
        )

    if tags:
        requested_tags = [tag.strip().lower() for tag in tags.split(",") if tag.strip()]
        if requested_tags:
            query = query.where(
                or_(*[Project.tags.cast(str).ilike(f"%{tag}%") for tag in requested_tags])
            )

    if min_rate is not None:
        query = query.where(Project.expected_hourly_rate >= min_rate)

    if max_rate is not None:
        query = query.where(Project.expected_hourly_rate <= max_rate)

    query = query.order_by(Project.created_at.desc())
    return list(db.scalars(query).all())


def create_project(db: Session, user: User, payload: ProjectCreate) -> Project:
    project = Project(
        buyer_id=user.id,
        title=payload.title,
        description=payload.description,
        expected_hourly_rate=payload.expected_hourly_rate,
        expected_duration_hours=payload.expected_duration_hours,
        tags=payload.tags,
        is_open=True,
    )
    db.add(project)
    db.commit()
    db.refresh(project)
    return project
