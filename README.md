# paid_task (Flutter App)

Step-by-step guide to run the project locally.

## 1. Prerequisites

Install these first:

- Flutter SDK (tested with Flutter `3.41.4`, Dart `3.11.1`)
- Android Studio (for Android SDK/emulator) and/or Xcode (for iOS Simulator on macOS)
- Git

Verify setup:

```bash
flutter doctor
```

Fix anything marked as required before continuing.

## 2. Clone and open the project

```bash
git clone <your-repo-url>
cd task-platform-app
```

## 3. Install dependencies

```bash
flutter pub get
```

## 4. Configure backend API URL (important)

This app calls backend endpoints from:

- `lib/utils/constants.dart`
- `ApiConstants.baseUrl`

Current value:

```dart
static const String baseUrl = 'http://192.168.0.108:8000/api/v1';
```

Change this to your local backend URL if needed.

Common cases:

- Android emulator: `http://10.0.2.2:8000/api/v1`
- iOS simulator: `http://127.0.0.1:8000/api/v1`
- Physical device: `http://<YOUR_COMPUTER_LAN_IP>:8000/api/v1`

## 5. Start your backend server

Run your API server so it is reachable at the `baseUrl` you set above.

The app will not work correctly without a running backend.

## 6. Run the Flutter app

List devices:

```bash
flutter devices
```

Run app:

```bash
flutter run
```

Run on a specific device:

```bash
flutter run -d <device_id>
```

## 7. Verify code health

Run analyzer:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## 8. Useful troubleshooting

- If dependencies fail: `flutter clean && flutter pub get`
- If device not detected: re-run `flutter doctor` and fix toolchain issues
- If API calls fail: confirm `baseUrl`, backend status, and firewall/network access
