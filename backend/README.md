# Backend

Minimal FastAPI backend for the Flutter showcase app.

## Setup

For iOS Simulator or other same-machine clients:

```bash
cd backend
cp .env.example .env
uv sync --extra dev
uv run alembic upgrade head
uv run python scripts/seed_admin.py
uv run uvicorn app.main:app --reload
```

For a physical device on your local network, bind Uvicorn to all interfaces:

```bash
cd backend
cp .env.example .env
uv sync --extra dev
uv run alembic upgrade head
uv run python scripts/seed_admin.py
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API base URL for same-machine clients:

```text
http://127.0.0.1:8000/api/v1
```

API base URL for physical devices:

```text
http://<YOUR_COMPUTER_LAN_IP>:8000/api/v1
```

## Notes

- Public signup supports `buyer` and `developer`.
- Admin access is created through `scripts/seed_admin.py`.
- Task files are stored under `backend/uploads/tasks/`.
- Payments use Stripe test mode and a fixed demo payment method.
