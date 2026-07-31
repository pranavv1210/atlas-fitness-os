# Atlas

**A premium personal fitness operating system for Android.**

Atlas is a production-grade fitness application built to make training,
hydration, goals, body metrics, and progress feel organized instead of
scattered. It combines fast workout logging, a large exercise library, Google
account separation, Supabase sync, reminders, biometric protection, and a
premium mobile-first interface.

Atlas is designed for people who want the structure of a serious fitness app
without the noise of social feeds, ads, gamified clutter, or generic health
dashboards.

## Product Status

Atlas is a functional Android app with a separate React marketing website.

- Flutter Android app with production release APK support
- Google Sign-In authentication
- Supabase-backed user data and sync
- Atlas AI Agent overlay backed by Supabase Edge Functions
- Workout logging with sets, reps, weight, and exercise selection
- Workout templates and 5-day workout cycle
- Expanded exercise library with 2,069 unique exercises
- Exercise search across names, muscles, equipment, difficulty, patterns, and
  instructions
- Simple muscle filters for Chest, Back, Legs, Shoulders, Arms, Abs, Glutes,
  Triceps, Biceps, and Cardio
- Weight tracking, hydration tracking, goals, progress, and profile screens
- Notification scheduling for reminders and hydration intervals
- Biometric lock support
- Light and dark mode
- Premium React landing page in `landing/`

## Repository Structure

```text
atlas-fitness-os/
  android/        Android platform project
  assets/         Bundled app assets and exercise data
  config/         Local runtime configuration templates
  docs/           Product, architecture, backend, and roadmap documentation
  landing/        Standalone React + Vite marketing website
  lib/            Flutter application source
  supabase/       Database migrations, seed data, and storage placeholders
  test/           Flutter tests
```

The landing website is isolated in `landing/` and does not modify or depend on
Flutter mobile code.

## Mobile App

### Core Experience

Atlas opens with a splash/auth flow, restores the user session, loads the
profile, then enters the main app shell:

```text
Splash
Initialize services
Check authentication
Restore session or Google login
Load profile
Atlas app shell
```

The primary tabs are:

- **Today**: daily focus, training status, hydration, weight, and quick actions
- **Train**: workout cycle, exercise picker, logging, and saved workouts
- **Progress**: body and training progress views
- **Goals**: goal creation and tracking
- **Me**: profile, preferences, sync, biometric lock, and logout

### Atlas AI Agent

Atlas includes a floating AI companion overlay inside the app shell. It is
designed to feel like a personal trainer, gym buddy, and log analyst rather than
a separate chatbot screen.

The agent can read the signed-in user's Atlas context through Supabase:

- today's workout and current cycle
- recent workout logs, exercises, sets, reps, and weight
- workout streak and recent training dates
- active goals
- body weight logs
- hydration count for today
- relevant exercise library records

The Flutter app calls the `atlas-agent` Supabase Edge Function. The OpenAI API
key must stay server-side as a Supabase secret and must never be added to the
Flutter app.

Deploy the function:

```powershell
supabase functions deploy atlas-agent
```

Set the AI secret:

```powershell
supabase secrets set OPENAI_API_KEY=your-openai-api-key
```

Optional model override:

```powershell
supabase secrets set OPENAI_MODEL=gpt-4.1-mini
```

If `OPENAI_API_KEY` is not configured, the function returns a safe local coach
fallback so the UI remains usable, but real AI coaching requires the secret.

### Exercise Library

Atlas ships with an expanded local exercise library:

- `2,069` unique exercises
- `2,049` exercises with instructions
- `870` exercises with images
- Searchable by exercise name, muscle, equipment, difficulty, movement pattern,
  movement type, and instruction text
- Simple user-friendly muscle filters

The bundled exercise data is available offline and is merged safely with
Supabase exercise records at runtime.

## Landing Website

The marketing site lives in `landing/` and is built with:

- React
- Vite
- TypeScript
- Inter
- Lenis smooth scrolling
- GSAP + ScrollTrigger
- Lucide React icons

It includes a premium product story, animated hero, phone mockup, exercise
library showcase, workout logging sequence, progress section, comparison,
download CTA, GitHub link, SEO metadata, and APK download route.

### Run Landing Locally

```powershell
cd landing
npm install
npm run dev
```

### Build Landing

```powershell
cd landing
npm run build
```

For Vercel:

- Root directory: `landing`
- Framework preset: `Vite`
- Build command: `npm run build`
- Output directory: `dist`

## Running The Flutter App

Install dependencies:

```powershell
flutter pub get
```

Run with local Dart defines:

```powershell
flutter run --dart-define-from-file=config/env/atlas.local.json
```

Build release APK:

```powershell
flutter build apk --release --dart-define-from-file=config/env/atlas.local.json
```

Release output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Configuration

Atlas reads runtime secrets through Dart defines. Do not hardcode credentials.

Required values:

```powershell
--dart-define=SUPABASE_URL=https://your-project.supabase.co
--dart-define=SUPABASE_ANON_KEY=your-anon-key
--dart-define=GOOGLE_WEB_CLIENT_ID=your-google-web-client-id
```

Optional owner restriction:

```powershell
--dart-define=ATLAS_OWNER_EMAIL=your-email@example.com
```

## Quality Checks

Recommended validation before shipping:

```powershell
flutter analyze
flutter test
flutter build apk --release --dart-define-from-file=config/env/atlas.local.json
cd landing
npm run build
npm audit --audit-level=high
```

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

## License

This project is maintained as the Atlas fitness application repository. Verify
third-party dataset and media licenses before redistributing exercise media.
