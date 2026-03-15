# Frontend

Flutter client for the task platform.

## Current scope

- Auth: login and registration
- Roles: buyer, developer, admin
- Buyer flow: create projects, review proposals, accept a proposal, track task progress, pay for submitted work, download paid files
- Developer flow: browse open projects, submit proposals, view assigned tasks, upload task deliverables
- Admin flow: dashboard stats for users, tasks, payments, and revenue

## API configuration

The app reads the backend base URL from `API_BASE_URL` at build time.

Default:

```text
http://127.0.0.1:8000/api/v1
```

Use cases:

- iOS simulator / same machine: default is correct
- Android emulator: `http://10.0.2.2:8000/api/v1`
- Physical device: `http://<YOUR_COMPUTER_LAN_IP>:8000/api/v1`

## Run locally

```bash
cd frontend
flutter pub get
flutter run
```

Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Physical device:

```bash
flutter run --dart-define=API_BASE_URL=http://<YOUR_COMPUTER_LAN_IP>:8000/api/v1
```

## Verification

```bash
flutter analyze
flutter test
```
