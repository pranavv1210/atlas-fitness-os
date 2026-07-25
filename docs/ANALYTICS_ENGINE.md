# Analytics Engine

The analytics engine turns raw logs into calm, useful insight. It should answer
personal questions without turning Atlas into a noisy dashboard.

## Purpose

### Why

Raw logs are not enough. The user needs to know whether training is consistent,
weight is trending, recovery is improving, and goals are on track. Analytics
should reduce cognitive load.

### How

Analytics should produce:

- Daily dashboard metrics
- Weekly summaries
- Monthly summaries
- Yearly summaries
- Workout frequency
- Weight trends
- Goal progress
- Recovery score
- Fitness score
- Cardio and sports summaries

## Weight Tracking

### Why

Daily weight can fluctuate, so Atlas should emphasize trends rather than single
readings. This keeps the experience calm and avoids overreacting.

### How

Conceptual calculations:

- Latest weight
- Seven-day moving average
- Thirty-day change
- Monthly trend direction
- BMI using profile height

Weight analytics should clearly label whether a value is raw or averaged.

## Mood, Energy, And Stress Tracking

### Why

Subjective wellness inputs explain training readiness in a way workout logs
cannot. They should be fast to enter and useful for recovery.

### How

Inputs:

- Mood
- Energy
- Stress
- Optional note

Suggested scale:

- 1 to 5 for each signal
- Higher mood and energy are positive
- Higher stress is negative

Analytics:

- Daily wellness snapshot
- Seven-day average
- Trend compared with previous week
- Recovery score input

## Recovery Score Logic

### Why

Recovery should help decide whether to push, maintain, or take it easy. It must
feel advisory, not medical.

### How

Conceptual inputs:

- Energy
- Stress
- Mood
- Recent workout load
- Rest day status
- Sleep quality, future optional
- Soreness, future optional

Conceptual output:

- 0 to 100 recovery score
- Label such as Low, Steady, Ready, Prime
- Short explanation

Suggested weighting for future implementation:

- Energy: strong positive input
- Stress: strong negative input
- Mood: moderate positive input
- Recent training density: moderate negative input if too high
- Rest day: positive adjustment

The first implementation should keep the formula transparent and easy to tune.

## Fitness Score Logic

### Why

Fitness score should summarize consistency and progress, not become a game. It
should help the user understand overall momentum at a glance.

### How

Conceptual inputs:

- Weekly workout completion
- Monthly workout frequency
- Weight trend alignment with goal
- Recovery stability
- Goal progress
- Cardio or sports activity, optional

Conceptual output:

- 0 to 100 fitness score
- Momentum label
- Dashboard explanation

Suggested categories:

- 0-39: Rebuild
- 40-59: Steady
- 60-79: Strong
- 80-100: Prime

## Goal Tracking Engine

### Why

Goals should be progress-oriented and non-punitive. Atlas should show whether
the user is moving toward the target without adding public pressure or badges.

### How

Goal types:

- Weight goal
- Strength goal
- Habit goal
- Deadline goal

Progress methods:

- Direct value comparison for weight and strength
- Count-based progress for habits
- Time-aware progress for deadline goals

Outputs:

- Percent complete
- Current value
- Target value
- On-track/off-track indication
- Next milestone

## Workout Frequency

### Why

Consistency matters more than streak punishment. Frequency gives a healthier
view of training behavior.

### How

Track:

- Workouts completed this week
- Workouts completed this month
- Average workouts per week
- Most trained muscle groups
- Rest days respected

Frequency should not reset lifetime progress after missed days.

## Summary Generation

### Why

Weekly, monthly, and yearly summaries make the data feel meaningful and help the
user reflect without manual analysis.

### How

Summary periods:

- Week
- Month
- Year

Each summary can include:

- Workouts completed
- Total sets
- Most trained muscle group
- Weight trend
- Recovery trend
- Goal progress
- Cardio minutes
- Sports sessions

## Analytics Storage Strategy

### Why

Some analytics can be calculated live, but long periods and dashboards benefit
from cached summaries.

### How

- Calculate small daily dashboard values on demand when practical.
- Cache expensive period summaries as snapshots.
- Include period start and period end on every summary.
- Recalculate snapshots when source logs change.
- Prefer source logs as the truth over derived summaries.
