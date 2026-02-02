# Eazy Talks - Flutter Frontend

Flutter mobile app for Eazy Talks with Firebase authentication and smooth UX.

## Setup

1. **Install Flutter dependencies:**
```bash
cd frontend
flutter pub get
```

2. **Configure Firebase:**
   - Install Firebase CLI: `npm install -g firebase-tools`
   - Run: `flutterfire configure`
   - This will create `lib/firebase_options.dart`

3. **Update API base URL:**
   - Edit `lib/core/constants/app_constants.dart`
   - Update `baseUrl` to match your backend URL

4. **Run the app:**
```bash
flutter run
```

## Project Structure

```
lib/
├── app/              # App-level configuration
│   ├── router/       # Navigation routes
│   └── widgets/      # Shared app widgets
├── core/             # Core utilities
│   ├── api/          # API client
│   ├── constants/    # App constants
│   ├── theme/        # App theme
│   └── utils/        # Utility functions
├── features/         # Feature modules
│   ├── auth/         # Authentication
│   ├── home/         # Home screen
│   ├── recent/        # Recent screen
│   ├── account/      # Account screen
│   └── user/         # User providers
└── shared/           # Shared components
    ├── models/       # Data models
    └── widgets/      # Reusable widgets
```

## Features

- ✅ Firebase Authentication (Phone + Email)
- ✅ Riverpod state management
- ✅ go_router navigation
- ✅ Skeleton loaders
- ✅ Smooth animations
- ✅ Error handling
- ✅ Persistent navigation bars

## Environment

- Flutter: 3.38.7
- Dart: 3.10.7
