# Data Flow

Atlas should feel fast and reliable even before every cloud operation succeeds.
The data flow architecture should separate UI, domain decisions, local cache,
sync, and Supabase.

## Current Phase

### Why

The current app is a polished mock-data prototype. Backend architecture should
be designed before implementation so future features do not grow around ad hoc
data access.

### How

No data flow is implemented in this phase. This document defines the future
target architecture.

## Future Layered Flow

### Why

Widgets should not know whether data came from Supabase, local cache, or a
pending offline write. Separating layers keeps the app maintainable.

### How

Future flow:

1. Screen asks feature state/controller for view data.
2. Feature state asks use case for domain data.
3. Use case asks repository for data.
4. Repository reads local cache first for speed.
5. Repository coordinates remote Supabase reads/writes.
6. Sync coordinator handles queued writes and conflicts.
7. Screen receives stable view state.

## Offline Cache Strategy

### Why

Atlas is online-first, but the user should not lose logs when network is poor.
The app should feel resilient without pretending cloud sync happened instantly.

### How

Conceptual cache responsibilities:

- Store recent profile, workout, goal, and metric data.
- Store pending write queue.
- Mark records with sync status.
- Support retry after network restoration.
- Show sync state in Profile.

Potential local states:

- Synced
- Pending create
- Pending update
- Pending delete
- Failed sync

## Write Strategy

### Why

Workout logging must feel immediate. Waiting for network round trips during a
session would damage the experience.

### How

Future write flow:

1. User logs action.
2. App writes to local cache.
3. UI updates immediately.
4. Sync queue sends change to Supabase.
5. Remote confirmation marks record synced.
6. Failure keeps record visible with a calm retry state.

## Read Strategy

### Why

Dashboards should open quickly while still refreshing from cloud.

### How

Future read flow:

1. Render cached data immediately.
2. Refresh remote data in background.
3. Merge remote updates.
4. Update derived summaries if source data changed.
5. Keep loading states subtle and localized.

## Conflict Strategy

### Why

Atlas is single-user, but conflicts can still happen across reinstalls or future
multiple devices.

### How

Suggested rules:

- New logs rarely conflict because they are append-only.
- Latest update wins for preferences.
- Soft delete wins over stale updates unless manually restored.
- For workout sets, preserve both conflicting edits when uncertain.
- Keep conflict metadata for future troubleshooting.

## Future Cloud Synchronization Strategy

### Why

Sync should protect personal history without making the app complex.

### How

Sync coordinator responsibilities:

- Track pending operations.
- Batch small writes where appropriate.
- Retry with backoff.
- Detect authentication errors.
- Detect network errors.
- Reconcile remote changes.
- Notify UI of sync health.

## UI States

### Why

Data architecture should support good UX, not just storage.

### How

Every feature should eventually model:

- Loading
- Empty
- Ready
- Optimistically updated
- Sync pending
- Sync failed
- Permission/auth required

These states should be calm and specific, not generic error screens.
