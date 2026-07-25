# Design System

Atlas should feel premium, calm, personal, and minimal.

## Tone

- Apple-like, but native to Android through Flutter Material 3
- Spacious and refined
- Clear hierarchy
- No busy dashboards
- No motivational clutter

## Color Direction

- Background: warm off-white with a subtle vertical wash
- Surface: clean white
- Warm surface: soft paper white
- Muted surface: warm gray
- Primary text: near black
- Secondary text: warm medium gray
- Soft text: low-emphasis gray
- Accent: premium blue
- Secondary accents: restrained green, amber, lilac, and rose
- Error: restrained red

Current tokens live in `lib/src/app/theme/atlas_colors.dart`.

## Components

- Cards use 8px radius, subtle borders, and low visual noise.
- Glassmorphism is allowed only for special surfaces where it improves depth.
- Bottom navigation uses personal labels: Today, Train, Progress, Goals, Me.
- Buttons should be clear, large enough to tap, and restrained.
- Progress rings, bars, and mock charts animate in with soft easing.
- Quick actions use compact icon-led controls.
- Repeated information uses calm cards, not dense tables.

## Motion

Motion should feel smooth and natural.

Planned use:

- Page transitions
- Card entrance animations
- Button micro-interactions
- Progress ring animation
- Progress bar and chart animation
- Tasteful workout completion confetti
- Subtle milestone celebrations

Avoid animation that slows down logging or makes common actions feel heavy.

## Typography

Use clean, highly readable typography. The current scaffold uses the platform
Roboto family with Cupertino-inspired text scale choices. Revisit custom fonts
only if they improve the product and do not add maintenance cost.
