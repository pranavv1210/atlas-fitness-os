# Supabase Plan

Atlas is online-first so data survives app deletion and device changes.

## Current Foundation

Supabase is installed and initialized only when these Dart defines are present:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

This keeps the app runnable before backend setup exists.

## Near-Term Backend Needs

Do not implement tables until the corresponding app feature is ready. Likely
early tables:

- `profiles`
- `exercise_library`
- `workout_logs`
- `workout_sets`
- `body_weight_logs`
- `wellness_logs`
- `hydration_events`
- `goals`

Because Atlas is single-user, keep the schema simple, but still include user
ownership fields so the app can rely on Supabase auth and row-level security.

## Offline-Friendly Direction

Atlas should eventually:

- Cache recent data locally.
- Allow logging when temporarily offline.
- Queue writes for sync.
- Show sync status in `Me`.
- Avoid data loss if the app is closed during a pending write.

The first foundation pass does not implement this logic.

## Phase 4 Backend Foundation

The backend foundation now lives under `supabase/`.

- Migration: `supabase/migrations/20260725090000_initial_atlas_backend.sql`
- Seed data: `supabase/seed.sql`
- Storage placeholders: `supabase/storage/`
- Implementation summary: `docs/BACKEND_IMPLEMENTATION.md`

The schema includes RLS, views, database helper functions, indexes, seed data,
and private storage buckets. Flutter feature logic is intentionally not wired to
these tables yet.
