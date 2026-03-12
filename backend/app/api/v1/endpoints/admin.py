from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import require_role
from app.models.user import User
from app.schemas.admin import AdminDashboardRead
from app.services.payment_service import get_admin_dashboard_stats


router = APIRouter()


@router.get("/dashboard", response_model=AdminDashboardRead)
def get_dashboard(
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("admin")),
) -> AdminDashboardRead:
    return AdminDashboardRead(**get_admin_dashboard_stats(db))
