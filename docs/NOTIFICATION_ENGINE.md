# Notification Engine

Notifications should support consistency without becoming noise. The engine
should feel like a personal assistant, not a marketing system.

## Purpose

### Why

Atlas can help the user remember workouts, hydration, wellness logging, and
weekly reflection. Poor notification design would make the app feel intrusive.

### How

Notification types:

- Morning greeting
- Workout reminder
- Water reminder
- Evening workout log reminder
- Wellness check-in
- Weekly summary
- Goal deadline reminder

## Scheduling Philosophy

### Why

The best reminder arrives at a useful time and stays quiet otherwise. Atlas
should respect routine, time zone, and rest days.

### How

Scheduling inputs:

- User time zone
- Preferred reminder times
- Quiet hours
- Current workout cycle day
- Recent activity
- Notification enabled state

## Hydration Nudges

### Why

The product direction is nudge-based hydration, not litre tracking. The engine
should keep this simple.

### How

Conceptual behavior:

- User configures reminder interval.
- App schedules local hydration reminders.
- User confirms "I drank water".
- Hydration event is logged.
- Next reminder is recalculated.

## Workout Reminders

### Why

Workout reminders should help start the session, but not punish missed days.

### How

Conceptual behavior:

- If today is a workout day, schedule reminder.
- If today is rest day, optionally show recovery prompt.
- If workout already completed, suppress reminder.
- If user ignores reminder, do not escalate aggressively.

## Weekly Summary

### Why

Reflection builds consistency. A weekly summary is more useful than daily
pressure.

### How

Conceptual behavior:

- Generate weekly summary after the week ends.
- Include workouts completed, weight trend, recovery trend, and goal progress.
- Show one concise notification.

## Local Versus Cloud Notifications

### Why

Atlas should work offline-friendly and avoid backend complexity early.

### How

Initial direction:

- Use local Android notifications for reminders.
- Store preferences locally and sync them later.
- Store notification events for history and troubleshooting.

Future direction:

- Cloud-assisted notifications only if multi-device behavior becomes important.

## Notification Data Model

### Why

Notification history helps prevent duplicates and improves scheduling decisions.

### How

Conceptual entities:

- Notification preference
- Notification schedule
- Notification event

Event states:

- Scheduled
- Shown
- Tapped
- Dismissed
- Suppressed

## Error Handling

### Why

Notification permissions can be denied. Atlas should handle that gracefully.

### How

- Show a calm permission state.
- Explain what reminders enable.
- Avoid repeated permission prompts.
- Let the user continue using Atlas without notifications.
