# Atlas

**Your Personal Fitness Operating System**

Atlas is a premium Android-only personal fitness app built for one user: Pranav.
It is designed to feel calm, modern, fast, and polished while staying simple
enough to build feature by feature.

Atlas is not a commercial fitness product. It has no social features, ads,
subscriptions, badges, XP systems, or public sharing. Its job is to make daily
fitness logging, consistency, recovery, hydration, body metrics, and goals feel
effortless.

## Current State

This repository contains the initial Flutter foundation and a premium mock-data
prototype:

- Android-only Flutter project scaffold
- Premium Atlas app shell with realistic mock UI
- Main navigation: Today, Train, Progress, Goals, Me
- Feature-first source structure
- Theme and design token foundation
- Supabase bootstrap configured by Dart defines
- Product and architecture docs in `docs/`
- Animated progress rings, charts, cards, and tab transitions

No workout, wellness, hydration, sync, or persistence business logic has been
implemented yet. The current app is intentionally presentation-only.

## Tech Direction

- **App:** Flutter
- **Platform:** Android only
- **Backend:** Supabase
- **Data posture:** Online-first with offline-friendly behavior planned
- **Architecture:** Feature-first, with UI, state, and data separated as
  features mature

## Running Locally

```powershell
flutter pub get
flutter run
```

To enable Supabase initialization:

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://your-project.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your-anon-key `
  --dart-define=GOOGLE_WEB_CLIENT_ID=your-google-web-client-id
```

For local development, this repo also supports an ignored local Dart define
file:

```powershell
flutter run --dart-define-from-file=config/env/atlas.local.json
```

Optional single-owner restriction:

```powershell
--dart-define=ATLAS_OWNER_EMAIL=your-email@example.com
```

No secrets are hardcoded in the repository. Supabase and Google credentials are
read from Dart defines at runtime/build time.

## Startup Flow

Atlas now starts through the infrastructure flow:

```text
Splash
Initialize services
Check authentication
Restore session
Load initial profile
Atlas shell
```

If no session exists, Atlas shows Google Sign-In. Logout is available from the
`Me` screen.

## Documentation

- [Masterplan](docs/MASTERPLAN.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Design System](docs/DESIGN_SYSTEM.md)
- [Product Roadmap](docs/ROADMAP.md)
- [Supabase Plan](docs/SUPABASE.md)
- [UI Review Report](docs/UI_REVIEW_REPORT.md)
- [Database Architecture](docs/DATABASE_ARCHITECTURE.md)
- [Workout Engine](docs/WORKOUT_ENGINE.md)
- [Analytics Engine](docs/ANALYTICS_ENGINE.md)
- [Supabase Architecture](docs/SUPABASE_ARCHITECTURE.md)
- [Backend Implementation](docs/BACKEND_IMPLEMENTATION.md)
- [Notification Engine](docs/NOTIFICATION_ENGINE.md)
- [Authentication](docs/AUTHENTICATION.md)
- [Data Flow](docs/DATA_FLOW.md)
