# Backend

FastAPI backend for the task platform, backed by PostgreSQL.

## Current scope

- JWT auth for buyer, developer, and admin roles
- Project creation and listing
- Proposal submission and project-level proposal review
- Proposal acceptance with task creation
- Task listing, task detail, task status updates, and task submission with file upload
- Payment creation for submitted tasks
- Paid file download for authorized users
- Admin dashboard stats

## Main routes

- `/api/v1/auth`
- `/api/v1/projects`
- `/api/v1/proposals`
- `/api/v1/tasks`
- `/api/v1/payments`
- `/api/v1/admin/dashboard`
- `/health`

## Run locally

```bash
cd backend
cp .env.example .env
uv sync --extra dev
uv run alembic upgrade head
uv run python scripts/seed_admin.py
uv run uvicorn app.main:app --reload
```

For a physical device on the same network:

```bash
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Notes

- Local same-machine base URL: `http://127.0.0.1:8000/api/v1`
- Physical-device base URL: `http://<YOUR_COMPUTER_LAN_IP>:8000/api/v1`
- Task uploads are stored under `backend/uploads/tasks/`
- Payments use Stripe test mode
