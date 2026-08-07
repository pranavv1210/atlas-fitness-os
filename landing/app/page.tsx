import Image from 'next/image';
import {
  Activity,
  BarChart3,
  CalendarDays,
  Download,
  Droplets,
  Dumbbell,
  Github,
  LockKeyhole,
  Search,
  ShieldCheck,
  Sparkles,
  Target,
  Timer,
  UserCheck,
} from 'lucide-react';
import { AtlasExperience } from '../components/atlas-experience';
import { GlassButton } from '../components/glass-button';
import { MobileMenu } from '../components/mobile-menu';
import { ProductPhone } from '../components/product-phone';
import { StoryShowcase } from '../components/story-showcase';

const apkUrl = '/downloads/atlas-release.apk';
const repoUrl = 'https://github.com/pranavv1210/atlas-fitness-os';

const proof = [
  ['2,069+', 'exercises'],
  ['5-day', 'cycle'],
  ['31', 'tables'],
  ['1 tap', 'water log'],
];

const features = [
  ['Workout OS', 'Daily training, builder, logger, history, and analytics live in one loop.', Activity],
  ['Atlas Buddy', 'Tell Buddy what you trained and it drafts exercises into your workout for review.', Sparkles],
  ['Goals', 'Strength, habit, weight, and hydration targets stay visible while you train.', Target],
  ['Private', 'Google login, separate accounts, sync, and biometric lock keep data personal.', LockKeyhole],
];

const productFeatures = [
  ['Google account login', 'Every user signs into a separate private workspace.', UserCheck],
  ['Workout logging', 'Track exercises, sets, reps, weight, duration-style cardio, and saved reports.', Dumbbell],
  ['2,069+ exercise library', 'Search movements with images, muscles, equipment, difficulty, and filters.', Search],
  ['Daily reports', 'Review workouts, hydration, cardio, sport, and weight by date.', CalendarDays],
  ['Progress analytics', 'Weekly volume, consistency, fitness score, recovery, and weight trend.', BarChart3],
  ['Hydration tracking', 'Quick sip logging, reminder intervals, and daily hydration context.', Droplets],
  ['Goals and streaks', 'Targets, weekly completion, cycle progress, and habit momentum.', Target],
  ['Atlas Buddy', 'Ask about logs, then describe today’s workout so Buddy drafts matched exercises for review.', Sparkles],
];

const securityPoints = [
  ['Separate accounts', 'Your logs are tied to your authenticated Google/Supabase user ID. Another account gets different data.'],
  ['Row level security', 'Private tables use Supabase RLS policies based on auth.uid(), so users can only access their own rows.'],
  ['Buddy scoped to you', 'Atlas Buddy receives your authenticated session and queries only your user-scoped logs.'],
  ['Local protection', 'Optional biometric lock helps protect the app on your device.'],
];

const competitors = [
  ['Notebook', 'Flexible but hard to search, compare, secure, sync, or turn into reports.', 'Atlas gives searchable logs, charts, reminders, and account security.'],
  ['Generic trackers', 'Often cluttered and disconnected from actual gym workflow.', 'Atlas keeps the training loop focused: today, train, report, progress.'],
  ['Hevy / Strong style apps', 'Excellent logging, but mostly centered around workouts.', 'Atlas adds hydration, goals, Buddy context, and a personal OS feel.'],
  ['Google Fit / Samsung Health', 'Great passive health hubs, weaker for structured gym progression.', 'Atlas is built around lifting, workout cycles, exercise selection, and reports.'],
];

export default function Home() {
  return (
    <AtlasExperience>
      <main>
        <header className="site-header">
          <nav className="site-nav" aria-label="Primary navigation">
            <a href="#top" className="brand-mark" aria-label="Atlas home">
              <Image src="/brand/atlas-logo.png" alt="" width={38} height={38} priority />
              <span>Atlas</span>
            </a>
            <div className="nav-links">
              <a href="#why">Why</a>
              <a href="#story">Experience</a>
              <a href="#features">Features</a>
              <a href="#security">Security</a>
              <a href="#download">Download</a>
            </div>
            <div className="nav-actions">
              <a className="icon-link" href={repoUrl} target="_blank" rel="noreferrer" aria-label="Open Atlas GitHub repository">
                <Github size={18} />
              </a>
              <a className="mini-cta" href={apkUrl} download>
                <span className="mini-cta-label">Download</span>
                <Download className="mini-cta-icon" size={15} />
              </a>
              <MobileMenu />
            </div>
          </nav>
        </header>

        <section id="top" className="hero-v2">
          <div className="hero-light" aria-hidden="true" />
          <div className="hero-v2-grid">
            <div className="hero-v2-copy">
              <div className="eyebrow reveal-blur">
                <Sparkles size={15} />
                Personal Fitness Operating System
              </div>
              <h1 className="hero-v2-title reveal-blur">Training, recovery, and progress in one disciplined loop.</h1>
              <p className="hero-v2-subtitle reveal-blur">
                Atlas replaces scattered notes and generic trackers with a premium Android app for workouts, exercises, hydration, history, goals, analytics, secure Google accounts, and a personal gym buddy.
              </p>
              <div className="cta-row reveal-blur">
                <GlassButton href={apkUrl} download icon={<Download size={18} />}>Download Atlas APK</GlassButton>
                <GlassButton href="#story" variant="quiet" icon={<Timer size={18} />}>See the system</GlassButton>
              </div>
              <div className="proof-strip reveal-blur">
                {proof.map(([value, label]) => (
                  <span key={label}><strong>{value}</strong>{label}</span>
                ))}
              </div>
            </div>

            <div className="hero-v2-phone reveal-blur">
              <ProductPhone mode="dashboard" />
              <div className="hero-card hero-card-a">Private Google account</div>
              <div className="hero-card hero-card-b">Fitness Score 78</div>
              <div className="hero-card hero-card-c">Buddy reads your logs</div>
            </div>
          </div>
        </section>

        <section id="why" className="why-v2">
          <div className="why-v2-statement">
            <span className="section-kicker">Why Atlas</span>
            <h2>A notebook records effort. Atlas turns effort into a system you can repeat.</h2>
          </div>
          <div className="comparison-row">
            <article>
              <span>Notebook</span>
              <p>Flexible, but impossible to search, compare, remind, protect, or turn into progress.</p>
            </article>
            <article className="comparison-active">
              <span>Atlas</span>
              <p>Workout logging, history, hydration, goals, analytics, account security, and Buddy context in one calm product.</p>
            </article>
            <article>
              <span>Generic apps</span>
              <p>Too much clutter, disconnected health widgets, and workflows that slow down training.</p>
            </article>
          </div>
        </section>

        <StoryShowcase />

        <section className="buddy-draft-v2">
          <div className="buddy-draft-panel">
            <div className="buddy-draft-copy">
              <span className="section-kicker">New In Atlas Buddy</span>
              <h2>Say what you did. Atlas builds the draft.</h2>
              <p>
                No more searching every movement while your pump is fading. Tell Atlas Buddy something like “shrugs 3x15 at 20 kg, pulldown 4x12, treadmill 20 minutes” and it matches the closest exercises from the library into today’s workout draft.
              </p>
              <p>
                Buddy does not complete the workout for you. It prepares the list, then you review, edit sets, reps, weight, or distance, and save only when it looks right.
              </p>
            </div>
            <div className="buddy-draft-demo" aria-label="Atlas Buddy workout drafting example">
              <div className="buddy-chat user">I did shrugs 3x15 20kg, lat pulldown 4x12 35kg</div>
              <div className="buddy-chat buddy">Matched Shrugs and Cable Pulldown. Added 2 exercises to today’s draft.</div>
              <div className="draft-card">
                <span>Workout draft</span>
                <strong>Shrugs</strong>
                <p>3 sets / 15 reps / 20 kg</p>
              </div>
              <div className="draft-card">
                <span>Closest library match</span>
                <strong>Cable Pulldown</strong>
                <p>4 sets / 12 reps / 35 kg</p>
              </div>
            </div>
          </div>
        </section>

        <section id="features" className="features-v2">
          <div className="section-heading">
            <span className="section-kicker">Built For Daily Use</span>
            <h2>Premium where it matters. Fast where it counts.</h2>
          </div>
          <div className="feature-grid-v2">
            {features.map(([title, body, Icon]) => (
              <article className="feature-v2-card" key={title as string}>
                <Icon size={22} />
                <h3>{title as string}</h3>
                <p>{body as string}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="inventory-v2">
          <div className="section-heading">
            <span className="section-kicker">What Atlas Includes</span>
            <h2>Not a tracker bolted together. A fitness system that keeps context.</h2>
          </div>
          <div className="inventory-grid">
            {productFeatures.map(([title, body, Icon]) => (
              <article className="inventory-card" key={title as string}>
                <Icon size={21} />
                <div>
                  <h3>{title as string}</h3>
                  <p>{body as string}</p>
                </div>
              </article>
            ))}
          </div>
        </section>

        <section id="security" className="security-v2">
          <div className="security-panel">
            <div>
              <span className="section-kicker">Security And Privacy</span>
              <h2>Your logs belong to your account. Not the device. Not another user.</h2>
              <p>
                Atlas uses Google sign-in, Supabase authenticated sessions, row level security, explicit user-scoped queries, and optional biometric lock. If another person signs in on another device, they see their own Atlas workspace, not yours.
              </p>
            </div>
            <div className="security-list">
              {securityPoints.map(([title, body]) => (
                <article key={title}>
                  <ShieldCheck size={20} />
                  <div>
                    <h3>{title}</h3>
                    <p>{body}</p>
                  </div>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section id="compare" className="market-v2">
          <div className="section-heading">
            <span className="section-kicker">Why It Is Different</span>
            <h2>Atlas is built for people who want structure without clutter.</h2>
          </div>
          <div className="market-grid">
            {competitors.map(([title, common, atlas]) => (
              <article className="market-card" key={title}>
                <h3>{title}</h3>
                <p>{common}</p>
                <strong>{atlas}</strong>
              </article>
            ))}
          </div>
        </section>

        <section className="stats-v2" aria-label="Atlas product statistics">
          {proof.map(([value, label]) => (
            <div className="stat-v2" key={label}>
              <strong data-count={value.replace(/\D/g, '') || '1'}>{value}</strong>
              <span>{label}</span>
            </div>
          ))}
        </section>

        <section id="terms" className="terms-v2">
          <div className="terms-card">
            <span className="section-kicker">Terms And Conditions</span>
            <h2>Clear rules before training starts.</h2>
            <div className="terms-grid">
              <p>Atlas is a personal fitness tracking application. It stores workouts, exercise selections, sets, reps, weights, hydration logs, cardio, sports, body weight, goals, reports, and app preferences for the signed-in user.</p>
              <p>Atlas Buddy can read your saved Atlas data to answer questions and give training context. It is not medical advice, injury diagnosis, emergency guidance, or a replacement for a qualified coach or clinician.</p>
              <p>Users are responsible for entering accurate data, training safely, protecting their Google account/device, and using Atlas lawfully. Do not share your account if you want your fitness history to remain private.</p>
            </div>
          </div>
        </section>

        <section id="download" className="download-v2">
          <div className="download-v2-card">
            <span className="section-kicker">Start Today</span>
            <h2>Make your next workout part of a system.</h2>
            <p>Download the current Android APK directly from the site. Sign in with Google, keep your data separate, and start using Atlas like a real fitness app from day one.</p>
            <div className="cta-row">
              <GlassButton href={apkUrl} download icon={<Download size={18} />}>Download Atlas APK</GlassButton>
              <GlassButton href={repoUrl} variant="quiet" icon={<Github size={18} />}>GitHub</GlassButton>
            </div>
          </div>
        </section>

        <footer className="site-footer">
          <a href="#top" className="brand-mark">
            <Image src="/brand/atlas-logo.png" alt="" width={28} height={28} />
            <span>Atlas</span>
          </a>
          <span>© 2026 Atlas Fitness. Personal fitness operating system.</span>
          <a className="icon-link" href={repoUrl} target="_blank" rel="noreferrer" aria-label="Open Atlas GitHub repository">
            <Github size={17} />
          </a>
        </footer>
      </main>
    </AtlasExperience>
  );
}
