from __future__ import annotations

import os
from pathlib import Path
from typing import Generator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool


TEST_DB_URL = "sqlite://"
TEST_UPLOADS_DIR = Path(__file__).resolve().parents[1] / "test_uploads"

os.environ.setdefault("JWT_SECRET_KEY", "test-secret")
os.environ.setdefault("STRIPE_SECRET_KEY", "sk_test_mocked")
os.environ.setdefault("UPLOADS_DIR", str(TEST_UPLOADS_DIR))

from app.core.config import get_settings
from app.core.database import Base, get_db
from app.main import app


@pytest.fixture()
def db_session() -> Generator[Session, None, None]:
    get_settings.cache_clear()
    TEST_UPLOADS_DIR.mkdir(parents=True, exist_ok=True)

    engine = create_engine(
        TEST_DB_URL,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        future=True,
    )
    TestingSessionLocal = sessionmaker(
        bind=engine,
        autoflush=False,
        autocommit=False,
        expire_on_commit=False,
        class_=Session,
    )
    Base.metadata.create_all(bind=engine)

    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()


@pytest.fixture()
def client(db_session: Session) -> Generator[TestClient, None, None]:
    def override_get_db() -> Generator[Session, None, None]:
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as api_client:
        yield api_client
    app.dependency_overrides.clear()


@pytest.fixture(autouse=True)
def clean_uploads() -> Generator[None, None, None]:
    if TEST_UPLOADS_DIR.exists():
        for child in TEST_UPLOADS_DIR.rglob("*"):
            if child.is_file():
                child.unlink()
        for child in sorted(TEST_UPLOADS_DIR.rglob("*"), reverse=True):
            if child.is_dir():
                child.rmdir()
    TEST_UPLOADS_DIR.mkdir(parents=True, exist_ok=True)
    yield
