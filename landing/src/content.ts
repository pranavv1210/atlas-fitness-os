import {
  Activity,
  BarChart3,
  CalendarClock,
  CheckCircle2,
  Dumbbell,
  Droplets,
  Fingerprint,
  Goal,
  LockKeyhole,
  Moon,
  Search,
  ShieldCheck,
  Sparkles,
  UserRoundCheck,
  Weight,
} from 'lucide-react';

export const repoUrl = 'https://github.com/pranavv1210/atlas-fitness-os.git';
export const apkUrl = '/downloads/atlas-release.apk';

export const features = [
  {
    icon: Dumbbell,
    title: 'Workout logging',
    text: 'Record exercises, sets, reps, and weight without slowing down your session.',
  },
  {
    icon: Search,
    title: '2,069+ exercises',
    text: 'A large searchable exercise library with muscles, equipment, difficulty, and instructions.',
  },
  {
    icon: CalendarClock,
    title: '5-day cycle',
    text: 'Follow a simple training rhythm across chest, back, arms, shoulders, legs, and rest.',
  },
  {
    icon: Droplets,
    title: 'Hydration',
    text: 'Track water intake and use reminder intervals that fit your day.',
  },
  {
    icon: Weight,
    title: 'Weight tracking',
    text: 'Log body weight and keep the long view of your physical progress.',
  },
  {
    icon: Goal,
    title: 'Goals',
    text: 'Turn intent into measurable targets across strength, weight, habits, and deadlines.',
  },
  {
    icon: BarChart3,
    title: 'Progress',
    text: 'See weekly completion, readiness, metrics, and trends in one calm dashboard.',
  },
  {
    icon: UserRoundCheck,
    title: 'Google login',
    text: 'Each user signs in with their own Google account so data stays separate.',
  },
  {
    icon: Fingerprint,
    title: 'Biometric lock',
    text: 'Protect the app with device biometrics when privacy matters.',
  },
  {
    icon: Moon,
    title: 'Dark and light',
    text: 'A premium interface that keeps the same disciplined feel in both modes.',
  },
];

export const stats = [
  ['2,069+', 'exercises'],
  ['4', 'templates'],
  ['5-day', 'cycle'],
  ['5', 'core tabs'],
  ['31', 'tables'],
  ['870', 'exercise images'],
];

export const comparison = [
  {
    title: 'Notebook',
    weak: 'Flexible but slow to search, easy to lose, and hard to analyze.',
    strong: 'Atlas keeps logging fast while making every workout searchable and structured.',
  },
  {
    title: 'Generic trackers',
    weak: 'Often crowded with social feeds, ads, and disconnected health widgets.',
    strong: 'Atlas stays focused on training, goals, hydration, progress, and account safety.',
  },
  {
    title: 'Cluttered gym apps',
    weak: 'Powerful features often hide behind noisy screens and heavy workflows.',
    strong: 'Atlas gives serious tracking in a calmer premium interface.',
  },
];

export const steps = [
  {
    title: 'Sign in',
    text: 'Start with Google login so every workout, goal, and profile stays attached to the right person.',
  },
  {
    title: 'Start training',
    text: 'Pick from templates, search the library, filter by muscle, and log your sets quickly.',
  },
  {
    title: 'Track progress',
    text: 'Review completion, weight, hydration, goals, and trends as the training cycle builds.',
  },
];

export const badges = [
  { icon: ShieldCheck, label: 'Account-separated data' },
  { icon: CheckCircle2, label: 'Built for daily use' },
  { icon: Sparkles, label: 'Premium app experience' },
  { icon: Activity, label: 'Fitness operating system' },
];
