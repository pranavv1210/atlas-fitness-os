/**
 * SITE - the single source of product truth for the landing page.
 *
 * EVERY claim below was verified against the Flutter app and the
 * Supabase schema in this repository. If you change a number here,
 * re-verify it in the app first. Marketing must match reality.
 *
 * Deliberately absent, because the app does not do these things:
 *   - streaks (the "streak" counter is a lifetime workout count)
 *   - workout duration (started_at and completed_at are written
 *     from the same timestamp, so every session is 0 seconds)
 *   - personal records, 1RM, RPE, rest timers (no implementation)
 *   - offline use (exercise imagery is remote; reads/writes hit the
 *     network; there is no sync queue)
 *   - automatic goal progress (one snapshot is written at creation
 *     and never recalculated)
 *   - hydration in ml or litres (it is an uncapped "sips" counter)
 *   - email/password sign-up (Google Sign-In only)
 *   - iOS or web (Android only; there is no ios/ directory)
 *   - ratings, reviews, download counts, company details
 */

export const SITE = {
  name: 'Atlas',
  tagline: 'Your personal fitness operating system',
  description:
    'Atlas is an Android training system: a five-day cycle that advances when you actually train, 873 exercises with reference imagery, set-by-set logging, and an assistant that reads your own record.',

  baseUrl: 'https://atlas-fitness-os-henna.vercel.app',
  repoUrl: 'https://github.com/pranavv1210/atlas-fitness-os',

  /** Verified: landing/public/downloads/atlas-release.apk, 57,318,622 bytes. */
  apkUrl: '/downloads/atlas-release.apk',
  apkVersion: '1.0.0',
  apkSize: '55 MB',
  apkBytes: 57_318_622,

  /** android/app/build.gradle.kts */
  packageId: 'com.pranav.atlas',
  minSdk: 23,
  minAndroid: 'Android 6.0',
  platform: 'Android',

  /**
   * Library counts. The bundled dataset holds 2,189 entries, but the
   * repository wraps every read in _exercisesWithMedia(), which drops
   * any entry without reference imagery - so 873 are actually
   * browsable, and each of those 873 has an image.
   */
  exercisesBrowsable: 873,
  exercisesBrowsableLabel: '873',
  exerciseWithImages: '873',
  exerciseWithInstructions: '2,184',
  exerciseCount: '2,189',
  datasetEntries: '2,189',

  /** supabase/ - verified table and policy counts. */
  tableCount: 31,
  policyCount: 47,

  /** The five-day cycle, in the app's own order and wording. */
  cycle: [
    { day: 1, name: 'Chest + Triceps', short: 'Push' },
    { day: 2, name: 'Back + Biceps', short: 'Pull' },
    { day: 3, name: 'Arms + Abs', short: 'Arms' },
    { day: 4, name: 'Shoulders + Legs', short: 'Lower' },
    { day: 5, name: 'Rest', short: 'Rest' },
  ],
  cycleDays: [
    { day: 'Day 1', title: 'Chest + Triceps', exercises: 'Bench, fly, pushdown', rest: false },
    { day: 'Day 2', title: 'Back + Biceps', exercises: 'Rows, pulldowns, curls', rest: false },
    { day: 'Day 3', title: 'Arms + Abs', exercises: 'Curls, extensions, crunches', rest: false },
    { day: 'Day 4', title: 'Shoulders + Legs', exercises: 'Press, squat, hinges', rest: false },
    { day: 'Day 5', title: 'Rest', exercises: 'Recovery and hydration', rest: true },
  ],

  /** The library's real filter chips, in the app's order. */
  muscleGroups: [
    'All',
    'Chest',
    'Triceps',
    'Back',
    'Biceps',
    'Legs',
    'Shoulders',
    'Arms',
    'Abs',
    'Glutes',
    'Cardio',
  ],

  /** The app's five bottom-dock destinations. */
  tabs: ['Today', 'Train', 'Progress', 'Goals', 'Me'],

  /** Hydration: a sip counter. The only target in the codebase is
   *  DAILY_SIP_TARGET in the Android home-screen widget. */
  sipTarget: 24,
  reminderDefaultMinutes: 120,
} as const;

/** Every href here must resolve to an element that exists on the page. */
export const NAV_LINKS = [
  { label: 'System', href: '#system' },
  { label: 'Training', href: '#training' },
  { label: 'Library', href: '#library' },
  { label: 'Assistant', href: '#assistant' },
  { label: 'FAQ', href: '#faq' },
] as const;

/** The record rail's sections, in scroll order. */
export const RECORD_SECTIONS = [
  { id: 'top', label: 'Atlas' },
  { id: 'problem', label: 'Drift' },
  { id: 'system', label: 'System' },
  { id: 'training', label: 'Training' },
  { id: 'library', label: 'Library' },
  { id: 'progress', label: 'Progress' },
  { id: 'assistant', label: 'Assistant' },
  { id: 'privacy-model', label: 'Data' },
  { id: 'faq', label: 'FAQ' },
  { id: 'download', label: 'Install' },
] as const;

/**
 * FAQ. Answers are deliberately blunt about limitations - an honest
 * "no" here is worth more than a soft yes that the app contradicts
 * five minutes after install. Mirrored into FAQPage JSON-LD.
 */
export const FAQ_ITEMS = [
  {
    q: 'What does Atlas cost?',
    a: 'Nothing. There are no ads, no subscription, and no in-app purchases - the app contains no billing or advertising code at all.',
  },
  {
    q: 'Which devices does it run on?',
    a: `Android phones running ${SITE.minAndroid} or newer. There is no iOS build and no web app today, so an iPhone cannot install it.`,
  },
  {
    q: 'Why is it a direct download instead of the Play Store?',
    a: 'Atlas is distributed as a signed APK you download from this page. Android will ask you to allow installs from your browser the first time; after that it installs like any other app.',
  },
  {
    q: 'Do I need an account?',
    a: 'Yes, and Google Sign-In is the only way in. There is no email-and-password option, so your workouts are tied to the Google account you choose on first launch.',
  },
  {
    q: 'Does Atlas work offline?',
    a: 'No, and it would be misleading to claim otherwise. Signing in needs a connection, your training record is read from and written to the server, and exercise reference images are loaded from the internet rather than bundled into the app.',
  },
  {
    q: 'How many exercises can I actually browse?',
    a: `${SITE.exercisesBrowsableLabel}. Atlas ships a ${SITE.datasetEntries}-entry open dataset and shows you the ${SITE.exercisesBrowsableLabel} that have reference imagery, because an exercise you cannot see is not much use when you are learning the movement. Search still reads the full dataset text.`,
  },
  {
    q: 'How does the five-day cycle work?',
    a: 'It advances on work, not on dates. Day 1 is Chest + Triceps, then Back + Biceps, Arms + Abs, Shoulders + Legs, and Rest. Skip Thursday and Thursday\'s session is simply the next one waiting - the cycle never runs ahead of you. You can also edit which exercises belong to each day.',
  },
  {
    q: 'What does the assistant actually do?',
    a: 'It answers questions about your own saved data - workouts, exercises, weight, hydration, cardio, goals and missed days - and can draft exercises into today\'s workout for you to review before saving. It runs server-side through a Supabase edge function and falls back to a simpler response if the model is unavailable.',
  },
  {
    q: 'Who can see my training data?',
    a: `Only you. Every one of the ${SITE.tableCount} tables in the database is protected by row-level security - ${SITE.policyCount} policies in total - so a query can only ever return rows belonging to the signed-in account. You can also require your fingerprint, face or device PIN before Atlas will open.`,
  },
  {
    q: 'Can I see the code?',
    a: 'Yes. The full source for both the app and this site is public on GitHub.',
  },
] as const;

export const APK_LABEL = `APK - ${SITE.apkSize} - v${SITE.apkVersion}`;
