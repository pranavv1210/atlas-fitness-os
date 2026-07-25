# Backend Implementation

Phase 4 creates the Supabase backend foundation for Atlas. It does not implement
Flutter feature logic.

## Created

- Initial migration: `supabase/migrations/20260725090000_initial_atlas_backend.sql`
- Seed data: `supabase/seed.sql`
- Storage placeholders:
  - `supabase/storage/avatars`
  - `supabase/storage/progress_photos`
  - `supabase/storage/exports`
- Local Supabase config: `supabase/config.toml`

## Schema Summary

The backend is single-user optimized but multi-user safe. Every personal record
is owned by an authenticated user through `profiles.id`, which references
`auth.users.id`.

Major table groups:

- Identity: `profiles`, `user_settings`, `default_settings`
- Workout engine: `workout_cycles`, `workout_days`, `workout_templates`,
  `workout_template_exercises`
- Exercise library: `exercise_categories`, `muscle_groups`, `equipment`,
  `exercises`, `exercise_muscle_groups`
- Workout logs: `workout_sessions`, `workout_session_exercises`, `workout_sets`
- Body and wellness: `body_weight_logs`, `wellness_logs`,
  `recovery_score_snapshots`, `fitness_score_snapshots`
- Hydration: `hydration_preferences`, `hydration_events`
- Goals: `goals`, `default_goal_templates`, `goal_progress_snapshots`,
  `goal_milestones`
- Activities: `cardio_sessions`, `sports_sessions`
- Motivation and notifications: `motivational_quotes`,
  `notification_preferences`, `notification_events`
- Sync foundation: `sync_change_log`

## Read Models

Read-only views were added for expected app queries:

- `v_today_workout`
- `v_weekly_progress`
- `v_latest_weight`
- `v_active_goals`
- `v_dashboard_summary`

## Database Functions

Small database functions were added only where they define backend primitives:

- `current_cycle_day`
- `get_today_workout`
- `advance_workout_cycle`
- `calculate_dashboard_summary`
- `generate_weekly_report`
- `set_updated_at`
- `is_record_owner`

## Security

Row Level Security is enabled on all application tables. Policies ensure:

- Users can only access their own personal records.
- System library data is read-only for authenticated users.
- Custom user exercises/templates are owner-scoped.
- Nested workout set access is checked through the owning workout session.
- Storage objects must live under a folder named with the authenticated user id.

## Storage

Private buckets are prepared for:

- `avatars`
- `progress_photos`
- `exports`

Bucket metadata is created in the migration, and local bucket configuration is
declared in `supabase/config.toml`.

## Seed Data

Seeds populate:

- Default settings
- Five-day Atlas workout cycle
- Workout days
- Exercise categories
- Muscle groups
- Equipment
- Exercise library
- Exercise muscle mappings
- Workout templates and template exercises
- Motivational quotes
- Default goal templates

User-owned data is intentionally not seeded because it depends on authenticated
users.

## Auth User Bootstrap

The migration adds `handle_new_auth_user`, a database trigger function that runs
after a Supabase Auth user is created. It prepares:

- `profiles`
- default `user_settings`
- `hydration_preferences`
- default `notification_preferences`

This keeps profile bootstrapping in the backend while Flutter feature logic
remains unimplemented.
