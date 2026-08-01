import Image from 'next/image';
import { Download, Github, Sparkles } from 'lucide-react';
import { AtlasExperience } from '../components/atlas-experience';
import { GlassButton } from '../components/glass-button';
import { PhoneStory } from '../components/phone-story';

const apkUrl = '/downloads/atlas-release.apk';
const repoUrl = 'https://github.com/pranavv1210/atlas-fitness-os';

const metrics = [
  ['2,069+', 'exercises'],
  ['870', 'exercise images'],
  ['5-day', 'training cycle'],
  ['31', 'database tables'],
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
              <a href="#story">Experience</a>
              <a href="#library">Library</a>
              <a href="#analytics">Progress</a>
              <a href="#download">Download</a>
            </div>
            <div className="nav-actions">
              <a className="icon-link" href={repoUrl} target="_blank" rel="noreferrer" aria-label="Open Atlas GitHub repository">
                <Github size={18} />
              </a>
              <a className="mini-cta" href={apkUrl} download>
                Download
              </a>
            </div>
          </nav>
        </header>

        <section id="top" className="opening-frame">
          <div className="ambient-field" aria-hidden="true">
            <span className="light-orbit light-orbit-a" />
            <span className="light-orbit light-orbit-b" />
            <span className="soft-grid" />
          </div>
          <div className="opening-copy">
            <div className="eyebrow reveal-blur">
              <Sparkles size={15} />
              Personal fitness operating system
            </div>
            <h1 className="hero-title reveal-blur">Atlas makes training feel inevitable.</h1>
            <p className="hero-subtitle reveal-blur">
              A premium Android fitness app for workout logging, 2,000+ exercises, goals, hydration, workout history, analytics, and Atlas Buddy.
            </p>
            <div className="hero-actions reveal-blur">
              <GlassButton href={apkUrl} download icon={<Download size={18} />}>
                Download Atlas APK
              </GlassButton>
              <GlassButton href={repoUrl} variant="quiet" icon={<Github size={18} />}>
                View GitHub
              </GlassButton>
            </div>
            <div className="hero-metrics reveal-blur">
              <span>Google login</span>
              <span>Biometric lock</span>
              <span>Atlas Buddy</span>
              <span>Tap-to-log hydration</span>
            </div>
          </div>
        </section>

        <PhoneStory />

        <section className="metrics-band" aria-label="Atlas product numbers">
          {metrics.map(([value, label]) => (
            <div className="metric-tile depth-card" key={label}>
              <strong data-count={value.replace(/\D/g, '') || '1'}>{value}</strong>
              <span>{label}</span>
            </div>
          ))}
        </section>

        <section id="download" className="download-section">
          <div className="download-card depth-card">
            <div className="section-kicker">Download</div>
            <h2>Start using Atlas today.</h2>
            <p>Download the current Android APK directly from the landing page and make the next workout part of a real system.</p>
            <div className="download-actions">
              <GlassButton href={apkUrl} download icon={<Download size={18} />}>
                Download Atlas APK
              </GlassButton>
              <GlassButton href={repoUrl} variant="quiet" icon={<Github size={18} />}>
                GitHub
              </GlassButton>
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
