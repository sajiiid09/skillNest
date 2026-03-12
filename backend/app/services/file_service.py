from pathlib import Path
import shutil

from fastapi import HTTPException, UploadFile, status

from app.core.config import get_settings


ALLOWED_EXTENSIONS = {".zip", ".rar", ".7z"}


def ensure_upload_directories() -> None:
    settings = get_settings()
    (settings.uploads_dir / "tasks").mkdir(parents=True, exist_ok=True)


def save_task_file(task_id: int, upload: UploadFile) -> str:
    suffix = Path(upload.filename or "").suffix.lower()
    if suffix not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only zip, rar, and 7z files are allowed",
        )

    ensure_upload_directories()
    settings = get_settings()
    target_dir = settings.uploads_dir / "tasks" / str(task_id)
    target_dir.mkdir(parents=True, exist_ok=True)
    target_path = target_dir / f"submission{suffix}"

    with target_path.open("wb") as file_buffer:
        shutil.copyfileobj(upload.file, file_buffer)

    return str(target_path)
