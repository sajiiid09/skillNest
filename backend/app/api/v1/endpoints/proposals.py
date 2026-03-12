from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user, require_role
from app.models.project import Project
from app.models.proposal import Proposal
from app.models.user import User
from app.schemas.proposal import ProposalCreate, ProposalRead
from app.services.proposal_service import (
    create_proposal,
    list_my_proposals,
    list_project_proposals,
    mark_proposal_accepted,
)


router = APIRouter()


def _serialize_proposal(proposal: Proposal) -> ProposalRead:
    return ProposalRead(
        id=proposal.id,
        project_id=proposal.project_id,
        cover_letter=proposal.cover_letter,
        proposed_hourly_rate=float(proposal.proposed_hourly_rate),
        estimated_hours=float(proposal.estimated_hours),
        status=proposal.status.value,
        developer_name=getattr(proposal.developer, "full_name", None),
        developer_email=getattr(proposal.developer, "email", None),
        created_at=proposal.created_at,
    )


def _get_owned_project_or_admin(db: Session, project_id: int, user: User) -> Project:
    project = db.get(Project, project_id)
    if project is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project not found")
    if user.role.value != "admin" and project.buyer_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to access this project",
        )
    return project


@router.get("/my-proposals", response_model=list[ProposalRead])
def get_my_proposals(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("developer")),
) -> list[ProposalRead]:
    return [_serialize_proposal(proposal) for proposal in list_my_proposals(db, current_user)]


@router.get("/project/{project_id}", response_model=list[ProposalRead])
def get_project_proposals(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[ProposalRead]:
    _get_owned_project_or_admin(db, project_id, current_user)
    proposals = list_project_proposals(db, project_id)
    return [_serialize_proposal(proposal) for proposal in proposals]


@router.post("/", response_model=ProposalRead, status_code=status.HTTP_201_CREATED)
def post_proposal(
    payload: ProposalCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("developer")),
) -> ProposalRead:
    proposal = create_proposal(db, current_user, payload)
    return _serialize_proposal(proposal)


@router.post("/{proposal_id}/accept", response_model=ProposalRead)
def accept_proposal(
    proposal_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ProposalRead:
    proposal = db.get(Proposal, proposal_id)
    if proposal is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Proposal not found")

    _get_owned_project_or_admin(db, proposal.project_id, current_user)
    proposal = mark_proposal_accepted(db, proposal)
    return _serialize_proposal(proposal)
