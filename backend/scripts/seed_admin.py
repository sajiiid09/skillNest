from sqlalchemy import select

from app.core.database import SessionLocal
from app.core.security import hash_password
from app.models.user import User, UserRole
from app.services.file_service import ensure_upload_directories
from app.core.config import get_settings


def main() -> None:
    settings = get_settings()
    ensure_upload_directories()

    with SessionLocal() as db:
        existing_user = db.scalar(select(User).where(User.email == settings.admin_email))
        if existing_user is not None:
            print(f"Admin already exists: {existing_user.email}")
            return

        admin = User(
            email=settings.admin_email,
            full_name=settings.admin_full_name,
            password_hash=hash_password(settings.admin_password),
            role=UserRole.ADMIN,
        )
        db.add(admin)
        db.commit()
        print(f"Created admin user: {settings.admin_email}")


if __name__ == "__main__":
    main()
