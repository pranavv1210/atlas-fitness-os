# Database Architecture

Atlas should preserve personal fitness history for years without making the app
feel like enterprise software. The database model must be simple enough for a
single user today, but disciplined enough that future multi-user support would
not require a rewrite.

No SQL or migrations are defined in this document. This is the conceptual data
model only.

## Design Principles

### Why

Fitness data becomes valuable over time. A single workout log is useful today,
but years of workouts, weight, wellness, hydration, goals, and summaries become
the real product. The model must protect historical truth while still allowing
the app to evolve.

### How

- Every user-owned record should have a stable identifier.
- Every user-owned record should belong to a user, even while Atlas is personal.
- Core logs should be append-friendly, not constantly overwritten.
- Derived scores should be reproducible from source logs where practical.
- User-facing deletes should be soft-delete capable for future recovery/sync.
- Timestamps should distinguish creation time, update time, and event time.

## Conceptual Entity Groups

### Identity And Profile

#### Why

Atlas is single-user today, but Supabase authentication and row-level security
need a clean ownership boundary. A profile also stores personal settings that
affect calculations such as BMI, workout cycle start date, and units.

#### How

Core entities:

- `User`: authentication identity owned by Supabase Auth.
- `Profile`: Atlas-specific user profile.
- `UserPreference`: settings such as units, appearance, reminder defaults, and
  privacy preferences.

Important profile concepts:

- Display name
- Height
- Date of birth, optional
- Primary unit system
- Workout cycle anchor date
- Default weekly workout target
- Time zone

### Exercise Library

#### Why

Workout logging must be fast. A preloaded exercise library prevents repetitive
typing and allows analytics to group work by muscle, equipment, and movement
pattern.

#### How

Core entities:

- `Exercise`: canonical exercise definition.
- `ExerciseMuscleTarget`: relationship between exercise and muscle groups.
- `MuscleGroup`: chest, triceps, back, biceps, arms, abs, shoulders, legs, etc.
- `Equipment`: barbell, dumbbell, cable, machine, bodyweight.
- `WorkoutTemplate`: planned routine day such as Chest + Triceps.
- `WorkoutTemplateExercise`: exercise prescription within a template.

Atlas should ship with a system library and allow user-created custom exercises
later. Custom exercises should never overwrite system definitions.

### Workout Logging

#### Why

Workout history is the core habit record. It must be flexible enough to support
sets and reps now, cardio and sports later, and analytics across frequency,
volume, muscle groups, and consistency.

#### How

Core entities:

- `WorkoutSession`: one performed workout.
- `WorkoutExercise`: one exercise inside a workout session.
- `WorkoutSet`: one logged set.
- `WorkoutNote`: optional notes for session or exercise context.

Important concepts:

- Session date and start/end time
- Workout day in the cycle
- Planned workout name
- Completion state
- Exercise order
- Set order
- Reps
- Weight/load, optional
- Effort or RPE, optional future field
- Rest duration, optional future field

### Body Metrics

#### Why

Weight and BMI tracking should be lightweight, because Atlas is not a medical
app. The goal is trend awareness, not clinical diagnosis.

#### How

Core entities:

- `BodyWeightLog`
- `BodyMeasurementLog`, future optional
- `HealthMetricSnapshot`, future optional derived snapshot

Important concepts:

- Measurement date
- Weight
- Unit at time of entry
- Optional note
- Derived BMI based on profile height

### Wellness Logs

#### Why

Mood, energy, and stress are subjective but useful for recovery and behavior
patterns. The model should keep raw daily inputs separate from derived scores.

#### How

Core entities:

- `WellnessLog`
- `RecoveryScoreSnapshot`
- `FitnessScoreSnapshot`

Important concepts:

- Mood rating
- Energy rating
- Stress rating
- Sleep quality, future optional
- Soreness, future optional
- Freeform note, optional
- Calculated recovery score
- Calculated fitness score

### Hydration

#### Why

Atlas only needs hydration nudges, not complex litre tracking. The database
should record simple confirmations and reminder preferences.

#### How

Core entities:

- `HydrationEvent`
- `HydrationPreference`

Important concepts:

- Confirmation time
- Reminder interval preference
- Quiet hours, future optional
- Notification enabled state

### Goals

#### Why

Goals should be motivating without becoming gamified. The model must support
weight, strength, habit, and deadline goals while preserving progress history.

#### How

Core entities:

- `Goal`
- `GoalProgressSnapshot`
- `GoalMilestone`

Important concepts:

- Goal type
- Target value
- Current value source
- Start date
- Deadline, optional
- Status
- Progress calculation method
- Milestone message

### Cardio And Sports

#### Why

Cardio and sports should be tracked simply, without distracting from strength
training. They are activity logs that can feed analytics and recovery.

#### How

Core entities:

- `CardioSession`
- `SportsSession`

Important concepts:

- Activity type
- Duration
- Distance, optional
- Intensity, optional
- Calories, optional future field
- Notes

### Notifications

#### Why

Notifications should support the daily experience without becoming noisy. The
database should store preferences and generated intent, not rely only on device
state.

#### How

Core entities:

- `NotificationPreference`
- `NotificationSchedule`
- `NotificationEvent`

Important concepts:

- Reminder type
- Enabled state
- Local time
- Last shown time
- Last acknowledged time
- Quiet hours

## Entity Relationships

### Why

Relationships determine how confidently Atlas can answer questions like "What
did I train this week?", "Am I recovering well?", and "Am I on track?"

### How

Primary relationships:

- User has one Profile.
- User has many Preferences.
- User has many WorkoutSessions.
- WorkoutSession has many WorkoutExercises.
- WorkoutExercise has many WorkoutSets.
- Exercise has many MuscleTargets.
- WorkoutTemplate has many WorkoutTemplateExercises.
- User has many BodyWeightLogs.
- User has many WellnessLogs.
- WellnessLog can produce RecoveryScoreSnapshot.
- User has many Goals.
- Goal has many GoalProgressSnapshots.
- User has many HydrationEvents.
- User has many NotificationEvents.

## Derived Data

### Why

Derived values make dashboards fast, but storing too much derived data can
create inconsistency. Atlas should store source logs first, then cache derived
snapshots only where they improve user experience.

### How

Source-of-truth logs:

- Workout sessions, exercises, sets
- Body weight logs
- Wellness logs
- Hydration events
- Goals

Derived snapshots:

- Recovery score
- Fitness score
- Goal progress
- Weekly summary
- Monthly summary
- Yearly summary

Derived snapshots should include enough metadata to know when they were
calculated and what period they describe.

## Deletion And History

### Why

Fitness logs are personal and occasionally sensitive. The user should be able
to correct mistakes while Atlas preserves enough structure for sync reliability.

### How

- Support soft-delete metadata conceptually on user-generated records.
- Keep immutable event timestamps separate from update timestamps.
- Prefer correction over destructive mutation for important historical records.
- Future export should include source logs and derived summaries.
