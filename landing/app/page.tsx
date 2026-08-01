import Image from 'next/image';
import type { LucideIcon } from 'lucide-react';
import { Github, ArrowRight, Download, Sparkles, Dumbbell, Droplets, Target, BarChart3, ShieldCheck } from 'lucide-react';
import { AtlasExperience } from '../components/atlas-experience';
import { GlassButton } from '../components/glass-button';
import { HeroPhoneClient } from '../components/hero-phone-client';

const apkUrl = '/downloads/atlas-release.apk';
const repoUrl = 'https://github.com/pranavv1210/atlas-fitness-os';

const features: Array<[string, string, LucideIcon]> = [
  ['Workout logging', 'Sets, reps, weight, notes, and saved reports without gym-floor friction.', Dumbbell],
  ['Atlas Buddy', 'A gym companion overlay that reads your logs and talks like someone training with you.', Sparkles],
  ['Hydration', 'Tap reminders to log water and keep daily basics visible.', Droplets],
  ['Goals', 'Strength, habit, weight, and deadline goals stay connected to training.', Target],
  ['Analytics', 'Workout history, trends, consistency, and progress without clutter.', BarChart3],
  ['Private by default', 'Google login, separate accounts, Supabase sync, and biometric lock.', ShieldCheck],
];

const stats = [
  ['2,069+', 'exercises'],
  ['870', 'exercise images'],
  ['5-day', 'training cycle'],
  ['31', 'database tables'],
  ['5/5', 'weekly rhythm'],
  ['1 tap', 'hydration logging'],
];

export default function Home() {
  return (
    <AtlasExperience>
      <main>
        <header className="fixed left-1/2 top-4 z-50 w-[min(1120px,calc(100%-24px))] -translate-x-1/2 rounded-full border border-white/65 bg-white/55 px-3 py-2 shadow-glass backdrop-blur-2xl">
          <nav className="flex items-center justify-between gap-3" aria-label="Primary navigation">
            <a href="#top" className="flex items-center gap-2 text-sm font-black text-atlas-ink">
              <Image src="/brand/atlas-logo.png" alt="" width={36} height={36} className="h-9 w-9 rounded-2xl shadow-glow" />
              <span>Atlas</span>
            </a>
            <div className="hidden items-center gap-8 text-xs font-bold text-atlas-muted md:flex">
              <a className="nav-link" href="#why">Why</a>
              <a className="nav-link" href="#experience">Experience</a>
              <a className="nav-link" href="#journey">Journey</a>
              <a className="nav-link" href="#download">Download</a>
            </div>
            <div className="flex items-center gap-2">
              <a className="icon-link" href={repoUrl} target="_blank" rel="noreferrer" aria-label="Open Atlas on GitHub">
                <Github size={18} />
              </a>
              <a className="mini-cta" href={apkUrl} download>
                Download
              </a>
            </div>
          </nav>
        </header>

        <section id="top" className="hero-shell">
          <div className="ambient-field" aria-hidden="true">
            <span className="light-orbit light-orbit-a" />
            <span className="light-orbit light-orbit-b" />
            <span className="soft-grid" />
          </div>

          <div className="mx-auto grid min-h-[100svh] w-[min(1220px,calc(100%-32px))] items-center gap-10 pt-28 lg:grid-cols-[0.92fr_1.08fr]">
            <div className="hero-copy">
              <div className="eyebrow reveal-blur">
                <Sparkles size={15} />
                Personal fitness operating system
              </div>
              <h1 className="hero-title reveal-words">
                Atlas makes training feel inevitable.
              </h1>
              <p className="hero-subtitle reveal-blur">
                Log workouts, track progress, follow a disciplined cycle, manage hydration, and train with Atlas Buddy in one premium Android app.
              </p>
              <div className="mt-8 flex flex-col gap-3 sm:flex-row">
                <GlassButton href={apkUrl} download icon={<Download size={18} />}>
                  Download Atlas APK
                </GlassButton>
                <GlassButton href="#experience" variant="quiet" icon={<ArrowRight size={18} />}>
                  Explore experience
                </GlassButton>
              </div>
              <div className="hero-metrics reveal-blur">
                <span>2,069+ exercises</span>
                <span>Atlas Buddy</span>
                <span>Tap-to-log hydration</span>
              </div>
            </div>
            <div className="hero-stage">
              <HeroPhoneClient />
              <div className="orbit-card orbit-card-a depth-card">
                <span>Today</span>
                <strong>Rest day</strong>
                <small>Recovery, mobility, hydration</small>
              </div>
              <div className="orbit-card orbit-card-b depth-card">
                <span>Atlas Buddy</span>
                <strong>We&apos;re locked in.</strong>
                <small>Reads your actual logs</small>
              </div>
              <div className="orbit-card orbit-card-c depth-card">
                <span>Hydration</span>
                <strong>Tap reminder</strong>
                <small>Logs 1 L instantly</small>
              </div>
            </div>
          </div>
        </section>

        <section id="why" className="story-section">
          <div className="section-kicker">Why Atlas</div>
          <div className="editorial-grid">
            <h2 className="section-title reveal-blur">A notebook records effort. Atlas turns it into a system.</h2>
            <div className="space-y-4 text-lg leading-8 text-atlas-muted reveal-blur">
              <p>Notebooks are flexible, but they cannot search, remind, compare, protect, or coach.</p>
              <p>Generic trackers collect everything and focus nothing. Atlas is built for the person who trains, logs, recovers, and comes back tomorrow.</p>
            </div>
          </div>
          <div className="problem-transform">
            {['random notes', 'missed water', 'forgot weights', 'no plan'].map((item) => (
              <div className="paper-note" key={item}>{item}</div>
            ))}
            <div className="system-core depth-card">
              <Image src="/brand/atlas-logo.png" alt="" width={42} height={42} />
              <strong>One disciplined loop</strong>
              <span>Train / Hydrate / Review / Repeat</span>
            </div>
          </div>
        </section>

        <section id="experience" className="experience-section">
          <div className="section-kicker">Experience</div>
          <h2 className="section-title max-w-4xl reveal-blur">Spatial app surfaces that move like a product, not a brochure.</h2>
          <div className="screen-rail">
            {['Today', 'Train', 'Exercise Library', 'Progress', 'Goals', 'Atlas Buddy'].map((screen, index) => (
              <article className="app-screen-card depth-card" key={screen}>
                <span>0{index + 1}</span>
                <h3>{screen}</h3>
                <div className="screen-lines">
                  <i />
                  <i />
                  <i />
                </div>
              </article>
            ))}
          </div>
        </section>

        <section className="features-section">
          <div className="section-kicker">Features</div>
          <div className="feature-grid">
            {features.map(([title, description, Icon]) => (
              <article className="feature-card depth-card" key={title as string}>
                <Icon className="feature-icon" size={22} />
                <h3>{title as string}</h3>
                <p>{description as string}</p>
              </article>
            ))}
          </div>
        </section>

        <section id="journey" className="journey-section">
          <div className="sticky-story">
            <div>
              <div className="section-kicker">Workout journey</div>
              <h2 className="section-title reveal-blur">Open Atlas. Start the day. Log the work. Let history talk back.</h2>
            </div>
            <div className="journey-stack">
              {['Sign in with Google', "Start today's workout", 'Add exercises', 'Save clean sets', 'Review the report'].map((step, index) => (
                <div className="journey-card depth-card" key={step}>
                  <span>{String(index + 1).padStart(2, '0')}</span>
                  <strong>{step}</strong>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="library-section">
          <div>
            <div className="section-kicker">Exercise library</div>
            <h2 className="section-title reveal-blur">Over 2,000 movements. Clean filters. Fast search.</h2>
          </div>
          <div className="library-panel depth-card">
            <div className="search-preview">bench</div>
            <div className="chip-cloud">
              {['All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Abs', 'Cardio'].map((chip) => <span key={chip}>{chip}</span>)}
            </div>
            <div className="exercise-preview-list">
              {['Dumbbell Bench Press', 'Incline Dumbbell Press', 'Cable Fly', 'Smith Machine Bench Press'].map((exercise) => <strong key={exercise}>{exercise}</strong>)}
            </div>
          </div>
        </section>

        <section className="analytics-section">
          <div className="section-kicker">Analytics</div>
          <h2 className="section-title reveal-blur">Progress that feels calm enough to read every day.</h2>
          <div className="stats-grid">
            {stats.map(([value, label]) => (
              <div className="stat-card depth-card" key={label}>
                <strong data-count={value.replace(/\D/g, '') || '1'}>{value}</strong>
                <span>{label}</span>
              </div>
            ))}
          </div>
        </section>

        <section className="roadmap-section">
          <div className="depth-card roadmap-card">
            <div>
              <div className="section-kicker">Future</div>
              <h2>Built in public. Open to testers, feedback, and collaborators.</h2>
            </div>
            <div className="roadmap-pills">
              <span>AI plan builder</span>
              <span>Exercise previews</span>
              <span>Workout insights</span>
              <span>Community feedback</span>
            </div>
          </div>
        </section>

        <section id="download" className="download-section">
          <div className="download-card depth-card">
            <div className="section-kicker">Start today</div>
            <h2>Download Atlas and make the next workout part of a system.</h2>
            <div className="mt-8 flex flex-col justify-center gap-3 sm:flex-row">
              <GlassButton href={apkUrl} download icon={<Download size={18} />}>
                Download APK
              </GlassButton>
              <GlassButton href={repoUrl} variant="quiet" icon={<Github size={18} />}>
                GitHub
              </GlassButton>
            </div>
          </div>
        </section>
      </main>
    </AtlasExperience>
  );
}
