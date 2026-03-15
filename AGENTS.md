# Project Development Notes

Keep this file current as the project evolves.

## Documentation rules

- Keep `frontend/README.md` and `backend/README.md` compact and current.
- Update documentation in the same change set as every feature, bug fix, API change, workflow change, or environment change.
- Document only what is actually implemented. Remove stale or speculative statements.
- Prefer brief sections: current scope, run instructions, configuration, and verification.

## Frontend rules

- The Flutter app must use `API_BASE_URL` via `--dart-define` for backend configuration.
- Default same-machine development target is `http://127.0.0.1:8000/api/v1`.
- For Android emulator use `10.0.2.2`.
- For physical devices use the host machine LAN IP.

## Backend rules

- Keep local same-machine development simple.
- When documenting physical-device testing, use Uvicorn bound to `0.0.0.0`.
- Keep route and capability summaries aligned with the actual API in `backend/app/api/v1/`.

## Maintenance rule

- If a future iteration changes app flow, roles, routes, setup, runtime config, or external integrations, update this file and both READMEs before closing the task.
