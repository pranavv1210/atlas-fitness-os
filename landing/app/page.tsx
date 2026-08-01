import Image from 'next/image';
import { Activity, Download, Github, LockKeyhole, Sparkles, Target, Timer } from 'lucide-react';
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
  ['Atlas Buddy', 'A gym companion that reads your logs and helps you understand what changed.', Sparkles],
  ['Goals', 'Strength, habit, weight, and hydration targets stay visible while you train.', Target],
  ['Private', 'Google login, separate accounts, sync, and biometric lock keep data personal.', LockKeyhole],
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
              <a href="#download">Download</a>
            </div>
            <div className="nav-actions">
              <a className="icon-link" href={repoUrl} target="_blank" rel="noreferrer" aria-label="Open Atlas GitHub repository">
                <Github size={18} />
              </a>
              <a className="mini-cta" href={apkUrl} download><span className="mini-cta-label">Download</span><Download className="mini-cta-icon" size={15} /></a>
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
                Atlas replaces scattered notes and generic trackers with a premium Android app for workouts, exercises, hydration, history, goals, analytics, and a personal gym buddy.
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
              <div className="hero-card hero-card-a">Workout streak 5</div>
              <div className="hero-card hero-card-b">Fitness Score 78</div>
              <div className="hero-card hero-card-c">Hydration on track</div>
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
              <p>Workout logging, history, hydration, goals, analytics, and AI context in one calm product.</p>
            </article>
            <article>
              <span>Generic apps</span>
              <p>Too much clutter, disconnected health widgets, and workflows that slow down training.</p>
            </article>
          </div>
        </section>

        <StoryShowcase />

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

        <section className="stats-v2" aria-label="Atlas product statistics">
          {proof.map(([value, label]) => (
            <div className="stat-v2" key={label}>
              <strong data-count={value.replace(/\D/g, '') || '1'}>{value}</strong>
              <span>{label}</span>
            </div>
          ))}
        </section>

        <section id="download" className="download-v2">
          <div className="download-v2-card">
            <span className="section-kicker">Start Today</span>
            <h2>Make your next workout part of a system.</h2>
            <p>Download the current Android APK directly from the site. Atlas is built for people who want their training to feel organized from day one.</p>
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
