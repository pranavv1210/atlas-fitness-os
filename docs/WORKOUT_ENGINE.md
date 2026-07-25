# Workout Engine

The workout engine decides what Atlas means by "today's workout", how a session
is logged, and how training data feeds progress. It should make the app feel
automatic and personal without hiding user control.

## Purpose

### Why

Atlas has a fixed training rhythm. The app should not ask the user to rebuild a
routine every day. The workout engine exists to remove decision fatigue and keep
logging under two minutes.

### How

The engine should:

- Determine the current cycle day.
- Present the planned workout.
- Suggest exercises from templates.
- Capture session completion.
- Log exercises, sets, reps, and optional load.
- Feed analytics, goals, recovery, and fitness score calculations.

## Fixed Workout Cycle

### Why

A five-day repeating cycle matches the intended personal routine and makes the
app feel tailored. It also avoids the complexity of calendar-based programming
too early.

### How

Cycle:

- Day 1: Chest + Triceps
- Day 2: Back + Biceps
- Day 3: Arms + Abs
- Day 4: Shoulders + Legs
- Day 5: Rest

Conceptual inputs:

- Workout cycle anchor date
- User time zone
- Optional pause/rest override in the future

Conceptual output:

- Current cycle day
- Workout label
- Planned exercise template
- Rest-day state when applicable

## Workout Session Lifecycle

### Why

The app should support fast logging today and richer analytics later. A clear
session lifecycle avoids ambiguous states such as partially logged workouts.

### How

States:

- Planned: shown for today but not started.
- In progress: user has opened or started logging.
- Completed: workout counts toward frequency and progress.
- Skipped: optional future state, should not punish the user.
- Deleted: user removed an incorrect session.

Important lifecycle moments:

- Session started
- Exercise added
- Set logged
- Session completed
- Completion summary generated

## Exercise Library Structure

### Why

Exercise selection should feel like choosing from a polished dropdown, not
manually typing data. Structured exercise metadata is also essential for muscle
group analytics.

### How

Exercise fields conceptually include:

- Name
- Primary muscle group
- Secondary muscle groups
- Equipment
- Movement pattern
- Default set target
- Default rep target
- Instructions, optional future content
- Active/inactive status
- Source: system or custom

Workout template exercise fields conceptually include:

- Exercise reference
- Display order
- Target sets
- Target reps
- Rest guidance, optional
- Notes

## Logging Model

### Why

Logging must be simple enough during training and structured enough after the
fact. The minimum useful log is exercise, sets, and reps. Load and effort can be
optional.

### How

Each workout session contains ordered exercises. Each exercise contains ordered
sets.

Set-level fields conceptually include:

- Set number
- Reps
- Weight/load, optional
- Completion state
- Effort/RPE, optional future field
- Notes, optional

## Rest Day Behavior

### Why

Rest should feel intentional, not like missing a workout. Atlas should support
recovery-focused UI and analytics on rest days.

### How

On Day 5:

- Today shows a rest mission.
- Train shows recovery guidance rather than exercise logging.
- Wellness and hydration become more prominent.
- Frequency calculations should not treat planned rest as failure.

## Completion And Delight

### Why

The completion moment is one of the few places where delight should be more
visible. It reinforces consistency without introducing badges or heavy
gamification.

### How

Future completion flow:

- Confirm workout summary.
- Show subtle celebration animation.
- Update weekly progress.
- Update workout count.
- Refresh recovery and fitness score snapshots.
- Offer a lightweight note or mood input.

## Future Flexibility

### Why

Atlas is personal today, but workout preferences can change. The engine should
not hard-code every future routine into app logic.

### How

- Store cycle definitions conceptually as templates.
- Keep the current five-day cycle as the default.
- Allow future template versioning.
- Preserve historical sessions with the template version used at the time.
