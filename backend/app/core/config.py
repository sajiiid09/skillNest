from functools import lru_cache
from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


BASE_DIR = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    project_name: str = "Task Platform API"
    api_v1_prefix: str = "/api/v1"
    database_url: str = (
        "postgresql+psycopg://postgres:postgres@localhost:5432/task_platform"
    )
    jwt_secret_key: str = "change-me-in-production"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 24
    stripe_secret_key: str = ""
    stripe_test_payment_method: str = "pm_card_visa"
    stripe_currency: str = "usd"
    admin_email: str = "admin@example.com"
    admin_password: str = "admin123456"
    admin_full_name: str = "Demo Admin"
    uploads_dir: Path = Field(default=BASE_DIR / "uploads")
    cors_origins: list[str] = ["*"]

    model_config = SettingsConfigDict(
        env_file=BASE_DIR / ".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
