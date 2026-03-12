from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.models.project import Project
from app.models.proposal import Proposal, ProposalStatus
from app.models.task import Task
from app.models.user import User
from app.schemas.proposal import ProposalCreate


def create_proposal(db: Session, user: User, payload: ProposalCreate) -> Proposal:
    project = db.get(Project, payload.project_id)
    if project is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project not found")

    if not project.is_open:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Project is no longer open for proposals",
        )

    existing_proposal = db.scalar(
        select(Proposal).where(
            Proposal.project_id == payload.project_id,
            Proposal.developer_id == user.id,
        )
    )
    if existing_proposal is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You have already submitted a proposal for this project",
        )

    proposal = Proposal(
        project_id=payload.project_id,
        developer_id=user.id,
        cover_letter=payload.cover_letter,
        proposed_hourly_rate=payload.proposed_hourly_rate,
        estimated_hours=payload.estimated_hours,
        status=ProposalStatus.PENDING,
    )
    db.add(proposal)
    db.commit()
    db.refresh(proposal)
    return proposal


def list_my_proposals(db: Session, user: User) -> list[Proposal]:
    query = (
        select(Proposal)
        .where(Proposal.developer_id == user.id)
        .order_by(Proposal.created_at.desc())
    )
    return list(db.scalars(query).all())


def list_project_proposals(db: Session, project_id: int) -> list[Proposal]:
    query = (
        select(Proposal)
        .options(joinedload(Proposal.developer))
        .where(Proposal.project_id == project_id)
        .order_by(Proposal.created_at.desc())
    )
    return list(db.scalars(query).all())


def mark_proposal_accepted(db: Session, proposal: Proposal) -> Proposal:
    proposal.status = ProposalStatus.ACCEPTED
    db.add(proposal)
    db.commit()
    db.refresh(proposal)
    return proposal


def create_task_from_proposal(db: Session, proposal: Proposal) -> Task:
    project = db.get(Project, proposal.project_id)
    if project is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project not found")

    existing_task = db.scalar(select(Task).where(Task.project_id == project.id))
    if existing_task is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Task already exists for this project",
        )

    if proposal.status == ProposalStatus.REJECTED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Rejected proposal cannot be accepted",
        )

    pending_proposals = db.scalars(
        select(Proposal).where(Proposal.project_id == project.id)
    ).all()
    for current_proposal in pending_proposals:
        if current_proposal.id == proposal.id:
            current_proposal.status = ProposalStatus.ACCEPTED
        elif current_proposal.status == ProposalStatus.PENDING:
            current_proposal.status = ProposalStatus.REJECTED
        db.add(current_proposal)

    task = Task(
        project_id=project.id,
        developer_id=proposal.developer_id,
        buyer_id=project.buyer_id,
        title=project.title,
        description=project.description,
        hourly_rate=proposal.proposed_hourly_rate,
        estimated_hours=proposal.estimated_hours,
    )
    project.is_open = False

    db.add(project)
    db.add(task)
    db.commit()
    db.refresh(task)
    return task
