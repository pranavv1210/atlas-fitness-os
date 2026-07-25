# Supabase Architecture

Supabase should provide cloud persistence, authentication, row-level security,
and a future sync backbone. Atlas should use it deliberately, not as a place to
put app logic too early.

## Purpose

### Why

Atlas data should survive app deletion and device changes. Supabase gives Atlas
managed Postgres, Auth, storage, and security primitives without paid backend
infrastructure.

### How

Supabase responsibilities:

- Authentication identity
- Cloud database
- Row-level access control
- Optional storage for future exports
- Future server-side functions only if genuinely needed

The Flutter app should not call Supabase directly from widgets. Future access
should go through feature repositories and sync-aware data services.

## Project Structure

### Why

A clear Supabase boundary avoids coupling UI screens to table shapes. It also
keeps future offline sync possible.

### How

Conceptual layers:

- Presentation layer: screens and widgets
- Domain layer: entities and use cases
- Data layer: repositories and DTOs
- Remote data source: Supabase client
- Local cache: offline store
- Sync coordinator: queue and reconciliation

## Data Ownership

### Why

Atlas is single-user today, but data ownership must be explicit to make security
and future scalability straightforward.

### How

Every user-owned cloud record should conceptually include:

- Owner user id
- Created timestamp
- Updated timestamp
- Optional deleted timestamp
- Sync version or revision metadata

System-owned records, such as built-in exercises, should be read-only to users.

## Row-Level Security Model

### Why

Fitness data is personal. The backend must enforce privacy even if client code
has a bug.

### How

Conceptual policies:

- Users can read their own records.
- Users can create their own records.
- Users can update their own records.
- Users can soft-delete their own records.
- Users can read active system exercise records.
- Users cannot modify system exercise records.

No policy SQL is defined in this phase.

## Edge Functions

### Why

Server functions add operational complexity. Atlas should avoid them until there
is a clear need for trusted backend computation.

### How

Avoid initially:

- Recovery score functions
- Fitness score functions
- Notification functions
- Analytics jobs

Consider later only for:

- Scheduled summary generation
- Export generation
- Complex sync reconciliation
- Push notification orchestration

## Storage

### Why

The first Atlas versions do not need files. Future exports may require storage,
but database records should remain the primary source of truth.

### How

Possible future storage:

- CSV exports
- PDF reports
- Backup bundles
- Profile image, optional

## Environment Strategy

### Why

Supabase setup should be safe to evolve and easy to test without risking the
main personal data set.

### How

Recommended environments:

- Local/mock mode for UI work
- Development Supabase project
- Production Supabase project for real personal data

The app should continue to run without Supabase configuration during UI-only
work.

## Future Scalability

### Why

Although Atlas is personal today, good boundaries make future multi-user support
possible.

### How

- Keep user ownership on all personal records.
- Avoid global mutable user settings.
- Keep system library records separate from custom records.
- Design summaries by user and period.
- Avoid assuming one user in backend data design.
