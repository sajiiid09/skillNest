from __future__ import annotations

from io import BytesIO

import pytest
from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.models.user import User, UserRole


def register_user(client, *, email: str, password: str, full_name: str, role: str) -> None:
    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": password,
            "full_name": full_name,
            "role": role,
        },
    )
    assert response.status_code == 201, response.text


def login_headers(client, *, email: str, password: str) -> dict[str, str]:
    response = client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": password},
    )
    assert response.status_code == 200, response.text
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def create_admin(db_session: Session) -> None:
    admin = User(
        email="admin@example.com",
        full_name="Admin User",
        password_hash=hash_password("adminpass123"),
        role=UserRole.ADMIN,
    )
    db_session.add(admin)
    db_session.commit()


@pytest.fixture()
def seeded_users(client):
    register_user(
        client,
        email="buyer@example.com",
        password="buyerpass",
        full_name="Buyer User",
        role="buyer",
    )
    register_user(
        client,
        email="developer@example.com",
        password="devpass123",
        full_name="Developer User",
        role="developer",
    )
    return {
        "buyer": login_headers(client, email="buyer@example.com", password="buyerpass"),
        "developer": login_headers(
            client,
            email="developer@example.com",
            password="devpass123",
        ),
    }


def test_register_and_reject_duplicate_email(client) -> None:
    register_user(
        client,
        email="person@example.com",
        password="secret123",
        full_name="Person One",
        role="buyer",
    )

    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": "person@example.com",
            "password": "secret123",
            "full_name": "Person Two",
            "role": "buyer",
        },
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "Email is already registered"


def test_login_returns_jwt_token(client) -> None:
    register_user(
        client,
        email="developer@example.com",
        password="devpass123",
        full_name="Developer User",
        role="developer",
    )

    response = client.post(
        "/api/v1/auth/login",
        json={"email": "developer@example.com", "password": "devpass123"},
    )

    assert response.status_code == 200
    body = response.json()
    assert "access_token" in body
    assert body["token_type"] == "bearer"


def test_full_showcase_flow(client, seeded_users, db_session: Session, monkeypatch) -> None:
    create_admin(db_session)
    buyer_headers = seeded_users["buyer"]
    developer_headers = seeded_users["developer"]
    admin_headers = login_headers(client, email="admin@example.com", password="adminpass123")

    project_response = client.post(
        "/api/v1/projects/",
        headers=buyer_headers,
        json={
            "title": "Build Flutter Demo",
            "description": "Need a Flutter developer for a showcase app",
            "expected_hourly_rate": 45,
            "expected_duration_hours": 12,
            "tags": ["flutter", "api"],
        },
    )
    assert project_response.status_code == 201, project_response.text
    project = project_response.json()
    project_id = project["id"]

    buyer_projects = client.get("/api/v1/projects", headers=buyer_headers)
    assert buyer_projects.status_code == 200
    assert len(buyer_projects.json()) == 1

    open_projects = client.get("/api/v1/projects", headers=developer_headers)
    assert open_projects.status_code == 200
    assert len(open_projects.json()) == 1
    assert open_projects.json()[0]["is_open"] is True

    proposal_response = client.post(
        "/api/v1/proposals/",
        headers=developer_headers,
        json={
            "project_id": project_id,
            "cover_letter": "I can deliver this quickly.",
            "proposed_hourly_rate": 50,
            "estimated_hours": 10,
        },
    )
    assert proposal_response.status_code == 201, proposal_response.text
    proposal_id = proposal_response.json()["id"]

    duplicate_proposal_response = client.post(
        "/api/v1/proposals/",
        headers=developer_headers,
        json={
            "project_id": project_id,
            "cover_letter": "Another try",
            "proposed_hourly_rate": 55,
            "estimated_hours": 9,
        },
    )
    assert duplicate_proposal_response.status_code == 400

    my_proposals_response = client.get(
        "/api/v1/proposals/my-proposals",
        headers=developer_headers,
    )
    assert my_proposals_response.status_code == 200
    assert len(my_proposals_response.json()) == 1

    project_proposals_response = client.get(
        f"/api/v1/proposals/project/{project_id}",
        headers=buyer_headers,
    )
    assert project_proposals_response.status_code == 200
    project_proposal = project_proposals_response.json()[0]
    assert project_proposal["developer_name"] == "Developer User"
    assert project_proposal["developer_email"] == "developer@example.com"

    accept_only_response = client.post(
        f"/api/v1/proposals/{proposal_id}/accept",
        headers=buyer_headers,
    )
    assert accept_only_response.status_code == 200
    assert accept_only_response.json()["status"] == "accepted"

    create_task_response = client.post(
        f"/api/v1/tasks/proposal/{proposal_id}/accept-and-create-task",
        headers=buyer_headers,
    )
    assert create_task_response.status_code == 200, create_task_response.text
    task = create_task_response.json()
    task_id = task["id"]
    assert task["status"] == "in_progress"

    closed_projects = client.get("/api/v1/projects", headers=developer_headers)
    assert closed_projects.status_code == 200
    assert closed_projects.json() == []

    my_tasks_response = client.get("/api/v1/tasks/", headers=developer_headers)
    assert my_tasks_response.status_code == 200
    assert len(my_tasks_response.json()) == 1

    buyer_task_list_response = client.get(
        f"/api/v1/projects/{project_id}/tasks",
        headers=buyer_headers,
    )
    assert buyer_task_list_response.status_code == 200
    assert len(buyer_task_list_response.json()) == 1

    task_details_response = client.get(
        f"/api/v1/tasks/{task_id}",
        headers=developer_headers,
    )
    assert task_details_response.status_code == 200

    pre_payment_download = client.get(
        f"/api/v1/tasks/{task_id}/download",
        headers=buyer_headers,
    )
    assert pre_payment_download.status_code == 400

    submit_response = client.post(
        f"/api/v1/tasks/{task_id}/submit",
        headers=developer_headers,
        data={"time_spent": "8.5"},
        files={
            "file": (
                "solution.zip",
                BytesIO(b"zip-content"),
                "application/zip",
            )
        },
    )
    assert submit_response.status_code == 200, submit_response.text
    submitted_task = submit_response.json()
    assert submitted_task["status"] == "submitted"
    assert submitted_task["solution_file_path"].endswith("submission.zip")

    unauthorized_project_tasks = client.get(
        f"/api/v1/projects/{project_id}/tasks",
        headers=developer_headers,
    )
    assert unauthorized_project_tasks.status_code == 403

    monkeypatch.setattr(
        "app.services.payment_service.stripe.PaymentIntent.create",
        lambda **kwargs: {"id": "pi_test_123", "status": "succeeded", **kwargs},
    )

    payment_response = client.post(
        "/api/v1/payments/",
        headers=buyer_headers,
        json={"task_id": task_id},
    )
    assert payment_response.status_code == 201, payment_response.text
    payment = payment_response.json()
    assert payment["provider"] == "stripe_test"
    assert payment["status"] == "paid"

    paid_task_response = client.get(
        f"/api/v1/tasks/{task_id}",
        headers=buyer_headers,
    )
    assert paid_task_response.status_code == 200
    assert paid_task_response.json()["status"] == "paid"

    download_response = client.get(
        f"/api/v1/tasks/{task_id}/download",
        headers=buyer_headers,
    )
    assert download_response.status_code == 200
    assert download_response.content == b"zip-content"

    admin_dashboard_response = client.get(
        "/api/v1/admin/dashboard",
        headers=admin_headers,
    )
    assert admin_dashboard_response.status_code == 200
    dashboard = admin_dashboard_response.json()
    assert dashboard["total_buyers"] == 1
    assert dashboard["total_developers"] == 1
    assert dashboard["total_projects"] == 1
    assert dashboard["total_tasks"] == 1
    assert dashboard["tasks_submitted"] == 0
    assert dashboard["tasks_completed"] == 1
    assert dashboard["total_revenue"] == 425.0


def test_permissions_block_wrong_roles(client, seeded_users, db_session) -> None:
    buyer_headers = seeded_users["buyer"]
    developer_headers = seeded_users["developer"]

    create_project_as_developer = client.post(
        "/api/v1/projects/",
        headers=developer_headers,
        json={
            "title": "Wrong role",
            "description": "Should fail",
            "expected_hourly_rate": 20,
            "expected_duration_hours": 4,
            "tags": [],
        },
    )
    assert create_project_as_developer.status_code == 403

    admin_dashboard_as_buyer = client.get(
        "/api/v1/admin/dashboard",
        headers=buyer_headers,
    )
    assert admin_dashboard_as_buyer.status_code == 403
