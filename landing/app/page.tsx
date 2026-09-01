import {
  BarChart3,
  Bell,
  CalendarDays,
  CheckCircle2,
  Dumbbell,
  Fingerprint,
  Flag,
  Github,
  Search,
  ShieldCheck,
  Weight,
} from 'lucide-react';
import { DownloadButton } from '../components/download-button';
import { Faq } from '../components/faq';
import { Footer } from '../components/footer';
import { Nav } from '../components/nav';
import { PhoneMock } from '../components/phone-mock';
import { SITE } from '@/lib/site';

const proof = [
  { value: SITE.exercisesBrowsableLabel, label: 'image-backed exercises' },
  { value: '5-day', label: 'training cycle' },
  { value: SITE.exerciseWithInstructions, label: 'with instructions' },
  { value: '31', label: 'private data tables' },
];

const flow = [
  {
    icon: Dumbbell,
    title: 'Train the next real workout',
    body: 'Miss Arms + Abs today and it stays next. The cycle advances only after you save the session you actually completed.',
  },
  {
    icon: CheckCircle2,
    title: 'Log sets without confusion',
    body: 'Add exercises, reps, weight, water, body weight, cardio, and sport logs into one daily record.',
  },
  {
    icon: BarChart3,
    title: 'Review progress from logs',
    body: 'Weekly completion, volume, goals, and body trends come from your actual saved history.',
  },
];

const goalTypes = [
  {
    icon: Weight,
    title: 'Weight goals',
    body: 'Set current and target body weight in kg. Future body logs keep progress visible.',
  },
  {
    icon: Dumbbell,
    title: 'Strength goals',
    body: 'Track a target lift or working weight, such as bench press or shoulder press.',
  },
  {
    icon: CalendarDays,
    title: 'Habit goals',
    body: 'Track weekly consistency, like completing 5 workouts every week.',
  },
  {
    icon: Bell,
    title: 'Goal reminders',
    body: 'If a goal is active and incomplete, Atlas can remind you to make progress.',
  },
];

const privacySignals = [
  {
    icon: ShieldCheck,
    title: 'Row-level security',
    body: 'Supabase policies scope each table row to the signed-in user.',
  },
  {
    icon: Fingerprint,
    title: 'Biometric lock',
    body: 'Optional device authentication protects the app before it opens.',
  },
  {
    icon: Flag,
    title: 'Private goals',
    body: 'Goals, workouts, weight, hydration, and reports stay on your account.',
  },
];

const faqData = [
  {
    question: 'What is Atlas?',
    answer:
      'Atlas is a personal fitness operating system for Android. It brings workout planning, logging, exercise discovery, history, hydration, goals, and progress analytics into one account-protected system.',
  },
  {
    question: 'Who is Atlas for?',
    answer:
      'Anyone who trains with structure. Beginners get a fixed five-day cycle and a curated exercise library. Experienced lifters get set-by-set history, weekly volume, body-weight trends, recovery context, and goal tracking.',
  },
  {
    question: 'How many exercises are included?',
    answer: `${SITE.exerciseCount} unique exercises are bundled with the app. ${SITE.exerciseWithInstructions} include step-by-step instructions and ${SITE.exerciseWithImages} include imagery.`,
  },
];

export default function Home() {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@graph': [
      {
        '@type': 'SoftwareApplication',
        name: 'Atlas Fitness OS',
        alternateName: 'Atlas',
        applicationCategory: 'HealthApplication',
        operatingSystem: 'Android',
        description: SITE.description,
        downloadUrl: `${SITE.baseUrl}/downloads/atlas-release.apk`,
        codeRepository: SITE.repoUrl,
        offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
      },
      {
        '@type': 'FAQPage',
        mainEntity: faqData.map((item) => ({
          '@type': 'Question',
          name: item.question,
          acceptedAnswer: { '@type': 'Answer', text: item.answer },
        })),
      },
    ],
  };

  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <a href="#main" className="skip-link">
        Skip to content
      </a>
      <Nav />
      <main id="main">
        <section id="top" className="overflow-hidden bg-atlas-paper pt-24">
          <div className="container-x grid min-h-[calc(100svh-96px)] items-center gap-10 py-12 md:grid-cols-[1.05fr_0.95fr] md:py-16">
            <div>
              <div className="kicker kicker-light">
                <span className="kicker-dot" />
                Personal Fitness Operating System
              </div>
              <h1 className="mt-5 max-w-3xl text-[clamp(44px,9vw,92px)] font-black leading-[0.95] tracking-normal text-atlas-ink">
                Your fitness.
                <br />
                <span className="text-atlas-blue">Finally organized.</span>
              </h1>
              <p className="mt-6 max-w-xl text-base leading-7 text-atlas-muted md:text-xl md:leading-8">
                Atlas plans your next workout, logs every set, tracks hydration and goals, and keeps
                your history tied to your Google account.
              </p>
              <div className="mt-8 flex flex-col gap-3 sm:flex-row">
                <DownloadButton />
                <a href="#system" className="btn btn-secondary">
                  See the system
                </a>
              </div>
              <p className="mt-5 text-xs font-black uppercase tracking-[0.14em] text-atlas-soft">
                Android APK v{SITE.apkVersion} - {SITE.apkSize} - Google sign-in
              </p>
            </div>
            <div className="mx-auto w-full max-w-[270px] md:max-w-[360px]">
              <PhoneMock mode="dashboard" />
            </div>
          </div>

          <div className="container-x grid gap-3 pb-16 sm:grid-cols-2 lg:grid-cols-4">
            {proof.map((item) => (
              <div key={item.label} className="rounded-3xl border border-atlas-line bg-white p-5 shadow-soft">
                <strong className="block text-3xl font-black text-atlas-ink">{item.value}</strong>
                <span className="mt-1 block text-sm font-bold text-atlas-muted">{item.label}</span>
              </div>
            ))}
          </div>
        </section>

        <section id="problem" className="bg-white py-20 md:py-24">
          <div className="container-x grid gap-10 md:grid-cols-[0.95fr_1.05fr] md:items-center">
            <div>
              <div className="kicker kicker-light">
                <span className="kicker-dot" />
                Why Atlas
              </div>
              <h2 className="mt-5 text-3xl font-black leading-tight text-atlas-ink md:text-5xl">
                Your training should not live in memory, notes, and screenshots.
              </h2>
              <p className="mt-5 text-base leading-7 text-atlas-muted md:text-lg">
                Every workout, sip, weight entry, and goal belongs in one record. Atlas keeps that
                record clean so tomorrow is obvious.
              </p>
            </div>
            <div className="grid gap-3">
              {['What did I train last?', 'How much did I lift?', 'Did I drink water today?', 'Which goal still needs work?'].map(
                (text) => (
                  <div key={text} className="rounded-2xl border border-atlas-line bg-atlas-paper p-5 text-lg font-black text-atlas-ink">
                    {text}
                  </div>
                ),
              )}
              <div className="rounded-2xl bg-atlas-blue p-5 text-lg font-black text-white shadow-glow">
                Atlas answers from your actual logs.
              </div>
            </div>
          </div>
        </section>

        <section id="system" className="bg-atlas-graphite py-20 text-white md:py-24">
          <div className="container-x">
            <div className="mx-auto max-w-3xl text-center">
              <div className="kicker kicker-dark justify-center">
                <span className="kicker-dot" />
                Connected System
              </div>
              <h2 className="mt-5 text-3xl font-black leading-tight md:text-6xl">
                One app for the work, the record, and the next step.
              </h2>
              <p className="mx-auto mt-5 max-w-2xl text-base leading-7 text-white/75 md:text-lg">
                The tabs are simple because the job is simple: today, train, progress, goals, and you.
              </p>
            </div>
            <div className="mt-12 grid gap-4 md:grid-cols-3">
              {flow.map((item) => {
                const Icon = item.icon;
                return (
                  <article key={item.title} className="rounded-3xl border border-white/10 bg-white/[0.06] p-6">
                    <Icon className="text-atlas-cyan" size={28} />
                    <h3 className="mt-5 text-2xl font-black leading-tight">{item.title}</h3>
                    <p className="mt-3 text-sm leading-6 text-white/70">{item.body}</p>
                  </article>
                );
              })}
            </div>
          </div>
        </section>

        <section id="training" className="bg-atlas-paper py-20 md:py-24">
          <div className="container-x grid gap-10 md:grid-cols-[0.95fr_1.05fr] md:items-center">
            <div className="mx-auto w-full max-w-[280px] md:max-w-[330px]">
              <PhoneMock mode="train" />
            </div>
            <div>
              <div className="kicker kicker-light">
                <span className="kicker-dot" />
                Training
              </div>
              <h2 className="mt-5 text-3xl font-black leading-tight text-atlas-ink md:text-5xl">
                Miss a day without breaking the plan.
              </h2>
              <p className="mt-5 text-base leading-7 text-atlas-muted md:text-lg">
                The cycle moves when a workout is logged, not when the date changes. That keeps Arms
                + Abs, Shoulders + Legs, and every report aligned with what you actually did.
              </p>
            </div>
          </div>
        </section>

        <section id="library" className="bg-white py-20 md:py-24">
          <div className="container-x grid gap-10 md:grid-cols-[1.05fr_0.95fr] md:items-center">
            <div>
              <div className="kicker kicker-light">
                <span className="kicker-dot" />
                Exercise Library
              </div>
              <h2 className="mt-5 text-3xl font-black leading-tight text-atlas-ink md:text-5xl">
                {SITE.exerciseCount} exercises. Searchable in seconds.
              </h2>
              <p className="mt-5 text-base leading-7 text-atlas-muted md:text-lg">
                Search by movement, muscle, equipment, difficulty, and instruction text. The app
                prioritizes exercises with reference imagery so the library stays useful.
              </p>
              <div className="mt-6 flex flex-wrap gap-2">
                {SITE.muscleGroups.slice(0, 9).map((muscle) => (
                  <span key={muscle} className="rounded-full border border-atlas-line bg-atlas-paper px-4 py-2 text-sm font-black text-atlas-ink">
                    {muscle}
                  </span>
                ))}
              </div>
            </div>
            <div className="rounded-[28px] border border-atlas-line bg-atlas-paper p-6 shadow-soft">
              <div className="flex h-14 items-center gap-3 rounded-full border border-atlas-line bg-white px-5 text-atlas-muted">
                <Search size={20} />
                <span className="font-bold">Search exercises</span>
              </div>
              <div className="mt-5 grid gap-3">
                {['Dumbbell Bench Press', 'Lat Pulldown', 'Shoulder Press'].map((name) => (
                  <div key={name} className="flex items-center justify-between rounded-2xl bg-white p-4">
                    <span className="font-black text-atlas-ink">{name}</span>
                    <span className="rounded-full bg-atlas-blue/10 px-3 py-1 text-xs font-black text-atlas-blue">Add</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        <section id="goals" className="bg-atlas-paper py-20 md:py-24">
          <div className="container-x">
            <div className="mx-auto max-w-3xl text-center">
              <div className="kicker kicker-light justify-center">
                <span className="kicker-dot" />
                Goals
              </div>
              <h2 className="mt-5 text-3xl font-black leading-tight text-atlas-ink md:text-5xl">
                Goals are now specific, not generic.
              </h2>
              <p className="mx-auto mt-5 max-w-2xl text-base leading-7 text-atlas-muted md:text-lg">
                Weight, strength, and habit goals use different fields in the app, so users know
                exactly what they are creating.
              </p>
            </div>
            <div className="mt-12 grid gap-4 md:grid-cols-2 lg:grid-cols-4">
              {goalTypes.map((item) => {
                const Icon = item.icon;
                return (
                  <article key={item.title} className="rounded-3xl border border-atlas-line bg-white p-6 shadow-soft">
                    <Icon className="text-atlas-blue" size={28} />
                    <h3 className="mt-5 text-xl font-black text-atlas-ink">{item.title}</h3>
                    <p className="mt-3 text-sm leading-6 text-atlas-muted">{item.body}</p>
                  </article>
                );
              })}
            </div>
          </div>
        </section>

        <section id="assistant" className="bg-atlas-graphite py-20 text-white md:py-24">
          <div className="container-x grid gap-10 md:grid-cols-[0.9fr_1.1fr] md:items-center">
            <div className="mx-auto w-full max-w-[270px] md:max-w-[320px]">
              <PhoneMock mode="progress" />
            </div>
            <div>
              <div className="kicker kicker-dark">
                <span className="kicker-dot" />
                Private Record
              </div>
              <h2 className="mt-5 text-3xl font-black leading-tight md:text-5xl">
                Your data stays tied to your account.
              </h2>
              <p className="mt-5 text-base leading-7 text-white/75 md:text-lg">
                Google sign-in, Supabase row-level security, and optional biometric lock keep the
                training record scoped to the person who owns it.
              </p>
              <div className="mt-6 grid gap-3 sm:grid-cols-3">
                {privacySignals.map((item) => {
                  const Icon = item.icon;
                  return (
                    <div key={item.title} className="rounded-2xl border border-white/10 bg-white/[0.06] p-4">
                      <Icon className="text-atlas-cyan" size={24} />
                      <h3 className="mt-4 text-sm font-black text-white">{item.title}</h3>
                      <p className="mt-2 text-xs leading-5 text-white/65">{item.body}</p>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </section>

        <Faq />

        <section id="download" className="bg-atlas-graphite py-20 text-white md:py-24">
          <div className="container-x text-center">
            <div className="kicker kicker-dark justify-center">
              <span className="kicker-dot" />
              Install
            </div>
            <h2 className="mx-auto mt-5 max-w-3xl text-4xl font-black leading-tight md:text-7xl">
              Your next workout is already waiting.
            </h2>
            <p className="mx-auto mt-6 max-w-xl text-base leading-7 text-white/75 md:text-lg">
              Download the signed Android APK, sign in with Google, and start building your record.
            </p>
            <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
              <DownloadButton />
              <a href={SITE.repoUrl} target="_blank" rel="noreferrer" className="btn btn-quiet-dark">
                <Github size={18} />
                GitHub
              </a>
            </div>
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
