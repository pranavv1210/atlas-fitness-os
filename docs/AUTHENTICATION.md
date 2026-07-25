# Authentication Architecture

Atlas is personal, but authentication is still important because cloud storage
needs ownership and privacy.

## Purpose

### Why

If the app is deleted or the phone changes, the user should be able to recover
fitness history. Authentication also enables row-level security in Supabase.

### How

Use Supabase Auth as the identity provider when backend work begins.

Authentication should remain invisible unless needed. Atlas should not feel like
a commercial account system.

## Single-User First

### Why

The app is built for Pranav. Supporting personal use well is more important than
building account-management complexity.

### How

Initial auth posture:

- One primary account.
- Minimal sign-in UI.
- No public profile.
- No friend discovery.
- No team or organization support.

## Future Multi-User Ready

### Why

The backend should not need a redesign if Atlas later supports another user or
device.

### How

- Use Supabase user id as ownership boundary.
- Keep profile records user-owned.
- Keep app settings user-owned.
- Do not hard-code personal data into backend records.

## Sign-In Options

### Why

The sign-in method should be reliable, low-friction, and free.

### How

Preferred options to evaluate later:

- Email magic link
- Email and password
- Google sign-in, if free and worth the setup

Initial architecture should not depend on any one UI flow.

## Session Management

### Why

Fitness logging should not be interrupted by frequent sign-ins.

### How

Conceptual behavior:

- Persist authenticated session securely.
- Refresh session through Supabase client.
- If session expires, keep local cached data visible.
- Queue writes until sign-in is restored, if safe.

## Privacy Lock

### Why

The app contains personal health-adjacent data. A device-level privacy lock may
be useful later.

### How

Future options:

- PIN
- Biometric unlock
- Android device credential

Privacy lock should protect local app access. It does not replace Supabase Auth.

## Security Principles

### Why

Authentication failures should not leak data or corrupt sync state.

### How

- Never store service role credentials in the app.
- Use publishable anon key only.
- Enforce row-level security in Supabase.
- Keep auth state separate from profile completeness.
- Treat sign-out as a local data safety event.
