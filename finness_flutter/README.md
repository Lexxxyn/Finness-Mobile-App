# FINNESS Mobile App

FINNESS is a Flutter fitness and wellness mobile app for tracking workouts, meals, sleep, calories, nutrition, and user profile goals. The app uses Firebase for authentication and cloud data storage, with local caching support so core data can still be read when the network is unavailable.

## Features

- Email authentication with login, registration, and forgot password screens
- Dashboard summary for daily health and fitness progress
- Workout library with detail, edit, and guided workout play screens
- Meal tracking by breakfast, lunch, snack, and dinner
- Recipe creation and meal library management
- Calories and nutrition summary pages
- Sleep tracking with sleep stage data
- Profile editing with fitness goal, body data, equipment, and photo support
- English and Indonesian localization
- Firebase Realtime Database sync with local cache and pending-write queue

## Tech Stack

- Flutter / Dart
- Firebase Core
- Firebase Authentication
- Firebase Realtime Database
- Cloud Firestore
- SQLite via `sqflite`
- `image_picker`
- `fl_chart`
- Material localization support

## Project Structure

```text
lib/
  constants/       App theme values
  core/            Language controller and localization state
  features/        Auth, dashboard, workout, meal, sleep, profile, summary UI
  models/          Shared app data models
  routes/          Route name constants
  services/        Firebase, auth, meal, workout, sleep, cache, and SQLite services
  widgets/         Shared UI components
```

## Requirements

- Flutter SDK with Dart `^3.12.2`
- Android Studio or Xcode for mobile builds
- A configured Firebase project
- Firebase platform configuration files generated for this app

## Getting Started

1. Clone the repository.

   ```bash
   git clone https://github.com/Lexxxyn/Finness-Mobile-App.git
   cd Finness-Mobile-App
   ```

2. Install dependencies.

   ```bash
   flutter pub get
   ```

3. Configure Firebase.

   This project expects `lib/firebase_options.dart` to exist and initialize Firebase through `DefaultFirebaseOptions.currentPlatform`. If you need to regenerate it, use FlutterFire CLI:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

4. Run the app.

   ```bash
   flutter run
   ```

## Common Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk
```

## Firebase Data

The app stores user-scoped data under Firebase Realtime Database paths such as:

```text
finnness/users/{uid}/profile
```

The service layer also keeps cached data locally and queues failed writes so they can be retried when the network is available.

## Notes

- The app currently uses Material routes rather than `go_router`, even though `go_router` is listed as a dependency.
- Keep Firebase keys, generated config, and database rules aligned with the Firebase project used for development or release.
- Run `flutter analyze` before pushing changes to catch lint and type issues.
