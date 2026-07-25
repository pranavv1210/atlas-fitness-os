# Architecture

Atlas uses a feature-first Flutter structure with shared app, core, and feature
areas.

## Source Layout

```text
lib/
  main.dart
  src/
    app/
      atlas_app.dart
      navigation/
      theme/
    core/
      config/
      services/
      widgets/
    features/
      today/
      train/
      progress/
      goals/
      me/
```

## Boundaries

- `app`: root application setup, theme, and navigation.
- `core`: cross-feature utilities, configuration, services, and shared widgets.
- `features`: product areas. Each feature owns its presentation and will later
  own state and data code.

## Feature Structure

As features mature, use this shape:

```text
features/<feature>/
  data/
  domain/
  presentation/
```

- `presentation`: widgets, screens, controllers, view state.
- `domain`: entities and use cases that are independent of storage.
- `data`: repositories, DTOs, Supabase/local cache implementations.

Do not create these folders until a feature needs them.

## State Management

No app-wide state package has been selected yet. Start with Flutter primitives
for placeholders. Add a state solution only when real feature state appears.

Preferred direction when needed:

- Keep state close to the feature.
- Use repositories for persistence boundaries.
- Keep Supabase calls out of widgets.
- Model sync and offline behavior explicitly.

## Supabase Boundary

Supabase is initialized in `core/services/supabase_bootstrap.dart` only when
`SUPABASE_URL` and `SUPABASE_ANON_KEY` are provided as Dart defines.

Future data code should hide Supabase behind repositories so UI code does not
depend directly on tables, queries, or sync mechanics.

## Testing Approach

- Widget tests for navigation and visible app behavior.
- Unit tests for workout cycle, recovery score, hydration rules, and summaries.
- Repository tests around Supabase/local cache boundaries once those exist.
