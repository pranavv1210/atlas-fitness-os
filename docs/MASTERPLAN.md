# Atlas Masterplan

**Tagline:** Your Personal Fitness Operating System

**Status:** Phase 4 backend foundation

## Vision

Atlas is a premium Android application built exclusively for Pranav.

It is a personal fitness operating system: a calm place to understand today,
train consistently, track progress, manage recovery, and stay aligned with
personal goals.

Atlas is not a public fitness network and not a commercial marketplace. It will
not include social features, ads, subscriptions, badges, XP systems, or public
sharing.

## Product Principles

- Personal over generic
- Calm over noisy
- Fast over exhaustive
- Beautiful over busy
- Consistency over streak punishment
- Useful metrics over vanity metrics
- Online-first cloud storage with offline-friendly app behavior

## Platform And Backend

- Platform: Android only
- Framework: Flutter
- Backend: Supabase for auth, database, and cloud persistence
- Tooling: free tools only
- Data posture: online-first, with local caching and sync resilience planned

## Core Navigation

- Today: daily overview, quote, mission, hydration, quick status
- Train: workout cycle, exercise selection, sets and reps logging
- Progress: body metrics, history, summaries, trends
- Goals: personal goals, habit targets, deadline targets
- Me: preferences, data controls, sync status, privacy settings

## Workout Cycle

Atlas follows a fixed repeating five-day cycle:

- Day 1: Chest + Triceps
- Day 2: Back + Biceps
- Day 3: Arms + Abs
- Day 4: Shoulders + Legs
- Day 5: Rest

The app should eventually determine the current workout automatically. Manual
override can be considered later, but it should not be the primary flow.

## Planned Feature Areas

- Daily overview dashboard
- Daily motivational quote that changes once per day
- Workout logging
- Exercise library with dropdown-style selection
- Sets and reps logging
- Workout history
- Body weight logging
- BMI and basic health metrics
- Water reminders and hydration nudges
- Mood, energy, and stress inputs
- Recovery score based on logged signals
- Goals tracking
- Weekly, monthly, and yearly summaries
- Workout frequency tracking
- Cardio tracking
- Simple sports log
- Offline-friendly behavior with cloud sync through Supabase
- Later: data export and privacy lock

## Backend Architecture Direction

Atlas remains single-user optimized, but backend ownership should be designed so
the system could eventually support more users without a full redesign.

Core architecture documents:

- [Database Architecture](DATABASE_ARCHITECTURE.md)
- [Workout Engine](WORKOUT_ENGINE.md)
- [Analytics Engine](ANALYTICS_ENGINE.md)
- [Supabase Architecture](SUPABASE_ARCHITECTURE.md)
- [Notification Engine](NOTIFICATION_ENGINE.md)
- [Authentication](AUTHENTICATION.md)
- [Data Flow](DATA_FLOW.md)

Phase 2 is documentation-only. It does not include migrations, SQL, Supabase
connection work, repositories, providers, APIs, authentication implementation,
notifications, persistence, or local database code.

## Phase 4 Backend Foundation

Phase 4 creates the Supabase backend foundation without building Flutter
features.

Implemented backend artifacts:

- Initial database migration
- Seed data
- Storage bucket configuration
- Row Level Security policies
- Read-only views
- Database helper functions
- Backend implementation documentation

See [Backend Implementation](BACKEND_IMPLEMENTATION.md).

## Backend Principles

- Source logs are the truth.
- Derived scores and summaries should be explainable.
- User ownership should exist on all personal records.
- Built-in library data should be separate from user-created data.
- Offline-friendly behavior should be designed before it is implemented.
- Supabase should be hidden behind future repository and sync boundaries.
- Security should rely on backend access control, not client trust.

## Non-Goals

- No social graph
- No public sharing
- No ads
- No subscriptions
- No badges or XP-heavy gamification
- No multi-user product complexity
- No backend business logic until the app data model needs it

## Success Criteria

- Atlas is useful every morning.
- Logging a workout takes less than two minutes.
- The UI feels premium, modern, and calm.
- The app protects data through Supabase-backed persistence.
- The codebase stays easy for Codex to extend feature by feature.
