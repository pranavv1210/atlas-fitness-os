import Lenis from 'lenis';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import {
  ArrowDown,
  ArrowRight,
  Check,
  Droplets,
  Github,
  LockKeyhole,
  Menu,
  Search,
  ShieldCheck,
  Sparkles,
  Bot,
  X,
} from 'lucide-react';
import { useEffect, useRef, useState } from 'react';
import { apkUrl, repoUrl } from './content';

gsap.registerPlugin(ScrollTrigger);

const storyFrames = [
  {
    label: 'Today',
    title: 'Chest + Triceps',
    metric: '5 moves',
    note: 'Day 1 is ready',
  },
  {
    label: 'Exercise Library',
    title: '2,069+ movements',
    metric: 'Search',
    note: 'Bench, cable, bodyweight',
  },
  {
    label: 'Workout Log',
    title: 'Decline Dumbbell Press',
    metric: '3 x 10',
    note: '42.5 kg saved',
  },
  {
    label: 'Progress',
    title: '0/5 week',
    metric: '+12%',
    note: 'Consistency trend',
  },
];

const features = [
  ['Atlas AI Agent', 'A gym-buddy overlay that reads workouts, goals, history, hydration, and progress.'],
  ['Workout logging', 'Sets, reps, weight, and notes stay fast enough for the gym floor.'],
  ['Exercise search', 'Find movements by name, muscle, equipment, difficulty, pattern, or instruction text.'],
  ['Simple filters', 'Chest, back, legs, arms, abs, shoulders, glutes, cardio. Clear and usable.'],
  ['Workout cycle', 'A disciplined 5-day rhythm keeps training moving without daily decision fatigue.'],
  ['Hydration', 'Reminder intervals and water logging keep the basics visible.'],
  ['Goals', 'Strength, habit, body weight, and deadline targets live beside training.'],
  ['Google login', 'Each person signs in with their own account, keeping data independent.'],
  ['Biometric lock', 'A privacy layer for a personal operating system.'],
];

const stats = [
  ['2069', 'exercises'],
  ['2049', 'with instructions'],
  ['870', 'with images'],
  ['5', 'core tabs'],
  ['4', 'templates'],
  ['31', 'database tables'],
];

const workoutRows = [
  ['Decline Dumbbell Press', '3 sets', '42.5 kg'],
  ['Cable Crossover', '3 sets', '12 reps'],
  ['Triceps Pushdown', '4 sets', '32 kg'],
];

function App() {
  const rootRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const prefersReducedMotion = window.matchMedia(
      '(prefers-reduced-motion: reduce)',
    ).matches;
    if (prefersReducedMotion) {
      document.querySelectorAll<HTMLElement>('[data-count]').forEach((element) => {
        const target = Number(element.dataset.count ?? '0');
        element.textContent = target.toLocaleString();
      });
      return;
    }

    const lenis = new Lenis({
      lerp: 0.08,
      wheelMultiplier: 0.88,
      touchMultiplier: 1.05,
      smoothWheel: true,
    });

    const tick = (time: number) => {
      lenis.raf(time * 1000);
    };

    gsap.ticker.add(tick);
    gsap.ticker.lagSmoothing(0);
    lenis.on('scroll', ScrollTrigger.update);

    const context = gsap.context(() => {
      gsap.fromTo(
        '.hero-word span',
        { yPercent: 112, rotateX: -28 },
        { yPercent: 0, rotateX: 0, duration: 1.1, stagger: 0.055, ease: 'power4.out' },
      );

      gsap.fromTo(
        '.hero-actions, .hero-badges',
        { opacity: 0, y: 26 },
        { opacity: 1, y: 0, duration: 0.72, stagger: 0.1, delay: 0.18, ease: 'power3.out' },
      );

      gsap.to('.phone-shell', {
        y: -26,
        rotateY: -8,
        rotateX: 5,
        scrollTrigger: {
          trigger: '.hero',
          start: 'top top',
          end: 'bottom top',
          scrub: 1.1,
        },
      });

      gsap.to('.float-card', {
        y: (index) => [-70, 44, -42, 64][index] ?? -36,
        x: (index) => [24, -34, 36, -22][index] ?? 0,
        rotate: (index) => [-6, 7, -4, 5][index] ?? 0,
        scrollTrigger: {
          trigger: '.hero',
          start: 'top top',
          end: 'bottom top',
          scrub: 1,
        },
      });

      const media = gsap.matchMedia();
      media.add('(min-width: 1024px)', () => {
        return gsap.to('.story-track', {
          xPercent: -72,
          ease: 'none',
          scrollTrigger: {
            trigger: '.story',
            start: 'top top',
            end: '+=2200',
            scrub: 1,
            pin: true,
            anticipatePin: 1,
          },
        });
      });

      gsap.fromTo(
        '.chaos-note',
        { opacity: 0, y: 80, rotate: -12, scale: 0.94 },
        {
          opacity: 1,
          y: 0,
          rotate: 0,
          scale: 1,
          duration: 0.9,
          stagger: 0.08,
          ease: 'power3.out',
          scrollTrigger: {
            trigger: '.transform-section',
            start: 'top 70%',
          },
        },
      );

      gsap.to('.chaos-note', {
        x: (index) => [260, 120, 310, 170][index] ?? 180,
        y: (index) => [80, -50, -10, 55][index] ?? 0,
        rotate: 0,
        scale: 0.72,
        opacity: 0,
        scrollTrigger: {
          trigger: '.transform-section',
          start: 'top 44%',
          end: 'bottom 55%',
          scrub: 1,
        },
      });

      gsap.fromTo(
        '.atlas-system',
        { opacity: 0, scale: 0.9, y: 50 },
        {
          opacity: 1,
          scale: 1,
          y: 0,
          scrollTrigger: {
            trigger: '.transform-section',
            start: 'top 38%',
            end: 'bottom 64%',
            scrub: 1,
          },
        },
      );

      gsap.fromTo(
        '.exercise-chip',
        { opacity: 0, y: 30 },
        {
          opacity: 1,
          y: 0,
          stagger: 0.045,
          ease: 'power3.out',
          scrollTrigger: {
            trigger: '.library-section',
            start: 'top 60%',
          },
        },
      );

      gsap.fromTo(
        '.log-row',
        { opacity: 0, x: -46 },
        {
          opacity: 1,
          x: 0,
          stagger: 0.16,
          scrollTrigger: {
            trigger: '.logging-section',
            start: 'top 58%',
          },
        },
      );

      gsap.fromTo(
        '.progress-bar span',
        { scaleX: 0 },
        {
          scaleX: 1,
          duration: 1.1,
          stagger: 0.1,
          ease: 'power3.out',
          scrollTrigger: {
            trigger: '.progress-section',
            start: 'top 62%',
          },
        },
      );

      gsap.utils.toArray<HTMLElement>('[data-count]').forEach((element) => {
        const target = Number(element.dataset.count ?? '0');
        const state = { value: 0 };
        gsap.to(state, {
          value: target,
          duration: 1.35,
          ease: 'power2.out',
          scrollTrigger: {
            trigger: element,
            start: 'top 82%',
            once: true,
          },
          onUpdate: () => {
            element.textContent = Math.round(state.value).toLocaleString();
          },
        });
      });

      gsap.utils.toArray<HTMLElement>('.reveal').forEach((element) => {
        gsap.fromTo(
          element,
          { opacity: 0, y: 42 },
          {
            opacity: 1,
            y: 0,
            duration: 0.85,
            ease: 'power3.out',
            scrollTrigger: {
              trigger: element,
              start: 'top 78%',
            },
          },
        );
      });

      return () => media.revert();
    }, rootRef);

    return () => {
      context.revert();
      lenis.destroy();
      gsap.ticker.remove(tick);
    };
  }, []);

  return (
    <div ref={rootRef} className="site">
      <Header />
      <Hero />
      <AgentShowcase />
      <Story />
      <Transformation />
      <Library />
      <Logging />
      <Progress />
      <Stats />
      <Comparison />
      <Download />
      <Footer />
    </div>
  );
}

function Header() {
  const [isOpen, setIsOpen] = useState(false);
  const closeMenu = () => setIsOpen(false);

  return (
    <header className={`nav-shell ${isOpen ? 'is-open' : ''}`}>
      <a className="brand" href="#top" aria-label="Atlas home">
        <img src="/brand/atlas-logo.png" alt="" />
        <span>Atlas</span>
      </a>
      <nav aria-label="Primary navigation">
        <a href="#story" onClick={closeMenu}>Story</a>
        <a href="#agent" onClick={closeMenu}>Agent</a>
        <a href="#library" onClick={closeMenu}>Library</a>
        <a href="#download" onClick={closeMenu}>Download</a>
      </nav>
      <div className="nav-actions">
        <a className="icon-button" href={repoUrl} target="_blank" rel="noreferrer" aria-label="Open Atlas on GitHub">
          <Github size={19} />
        </a>
        <a className="magnetic-button small" href={apkUrl} download>
          Download
        </a>
        <button
          className="menu-toggle"
          type="button"
          aria-label={isOpen ? 'Close navigation menu' : 'Open navigation menu'}
          aria-expanded={isOpen}
          onClick={() => setIsOpen((value) => !value)}
        >
          {isOpen ? <X size={19} /> : <Menu size={19} />}
        </button>
      </div>
      <div className="mobile-menu" aria-hidden={!isOpen}>
        <a href="#story" onClick={closeMenu}>Story</a>
        <a href="#agent" onClick={closeMenu}>Agent</a>
        <a href="#library" onClick={closeMenu}>Library</a>
        <a href="#download" onClick={closeMenu}>Download</a>
      </div>
    </header>
  );
}

function AgentShowcase() {
  return (
    <section className="agent-section" id="agent">
      <div className="agent-copy reveal">
        <p className="kicker">Atlas AI Agent</p>
        <h2>A trainer, gym buddy, and log analyst inside the app.</h2>
        <p>
          Atlas Agent reads your workout history, goals, hydration, body weight,
          current cycle, and exercise library to give personal guidance while
          you train.
        </p>
      </div>
      <div className="agent-stage" aria-label="Atlas Agent preview">
        <div className="agent-orb">
          <Bot size={34} />
        </div>
        <div className="agent-chat-card agent-card-one">
          <span>You</span>
          <strong>What should I train today?</strong>
        </div>
        <div className="agent-chat-card agent-card-two">
          <span>Atlas Agent</span>
          <strong>Continue Day 4. Keep shoulders controlled and legs moderate.</strong>
        </div>
        <div className="agent-chat-card agent-card-three">
          <span>Reads</span>
          <strong>Logs, goals, streak, hydration, weight, exercises</strong>
        </div>
      </div>
    </section>
  );
}

function Hero() {
  return (
    <section className="hero" id="top">
      <div className="ambient-layer" aria-hidden="true">
        <div className="mesh mesh-one" />
        <div className="mesh mesh-two" />
        <div className="light-ribbon ribbon-one" />
        <div className="light-ribbon ribbon-two" />
        <div className="particle-field">
          {Array.from({ length: 24 }, (_, index) => (
            <i key={index} style={{ '--i': index } as React.CSSProperties} />
          ))}
        </div>
      </div>

      <div className="hero-grid">
        <div className="hero-text">
          <div className="premium-pill">
            <Sparkles size={15} /> Personal fitness operating system
          </div>
          <h1 className="hero-word" aria-label="Atlas">
            {'Atlas'.split('').map((letter) => (
              <span key={letter}>{letter}</span>
            ))}
          </h1>
          <p className="hero-copy">
            The premium training app that turns scattered workouts, notes, goals, hydration, and progress into one calm system.
          </p>
          <div className="hero-actions">
            <a className="magnetic-button" href={apkUrl} download>
              Download Atlas APK <ArrowRight size={18} />
            </a>
            <a className="secondary-link" href="#story">
              Watch the story
            </a>
          </div>
          <div className="hero-badges" aria-label="Atlas highlights">
            <span>2,069+ exercises</span>
            <span>Google login</span>
            <span>Biometric lock</span>
          </div>
        </div>
        <div className="hero-device" aria-label="Atlas app preview">
          <PhoneMockup />
          <FloatingCard className="card-search" title="Exercise search" value="dumbbell bench" />
          <FloatingCard className="card-cycle" title="Workout cycle" value="Day 1 anchored" />
          <FloatingCard className="card-water" title="Hydration" value="Every 90 min" />
          <FloatingCard className="card-goal" title="Goal" value="5 sessions/week" />
        </div>
      </div>
      <a className="scroll-indicator" href="#story" aria-label="Scroll to Atlas story">
        <ArrowDown size={18} />
      </a>
    </section>
  );
}

function Story() {
  return (
    <section className="story" id="story">
      <div className="story-pin">
        <div className="story-intro">
          <p className="kicker">Scroll story</p>
          <h2>One phone. Your whole fitness life moving with it.</h2>
        </div>
        <div className="story-track">
          {storyFrames.map((frame, index) => (
            <article className="story-card" key={frame.title}>
              <span>{frame.label}</span>
              <h3>{frame.title}</h3>
              <strong>{frame.metric}</strong>
              <p>{frame.note}</p>
              <div className={`story-visual visual-${index + 1}`}>
                <i />
                <i />
                <i />
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}

function Transformation() {
  return (
    <section className="transform-section">
      <div className="section-copy reveal">
        <p className="kicker">Why Atlas</p>
        <h2>From scattered notes to a disciplined training system.</h2>
        <p>
          A notebook records effort. Atlas organizes it, searches it, protects it, and turns it into momentum.
        </p>
      </div>
      <div className="transform-stage" aria-label="Notebook notes transforming into Atlas">
        {['Chest day?', '83.7 kg', 'drink water', 'bench 42.5'].map((note) => (
          <div className="chaos-note" key={note}>{note}</div>
        ))}
        <div className="atlas-system">
          <div className="system-top">
            <img src="/brand/atlas-logo.png" alt="" />
            <span>Atlas System</span>
          </div>
          <div className="system-lines">
            <span />
            <span />
            <span />
          </div>
          <div className="system-grid">
            <b>Train</b>
            <b>Goals</b>
            <b>Hydrate</b>
            <b>Progress</b>
          </div>
        </div>
      </div>
    </section>
  );
}

function Library() {
  const chips = ['All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Abs', 'Glutes', 'Cardio'];
  const exercises = ['Decline Dumbbell Bench Press', 'Cable Crossover', 'Barbell Deadlift', 'Lat Pulldown'];

  return (
    <section className="library-section" id="library">
      <div className="library-shell">
        <div className="section-copy reveal">
          <p className="kicker">Exercise library</p>
          <h2>Over 2,000 movements, searchable in seconds.</h2>
          <p>
            Atlas helps users recognize, find, and add exercises without digging through crowded menus.
          </p>
        </div>
        <div className="library-ui" aria-label="Exercise picker preview">
          <div className="search-bar">
            <Search size={19} />
            <span>dumbbell bench</span>
          </div>
          <div className="chip-row">
            {chips.map((chip) => (
              <span className="exercise-chip" key={chip}>{chip}</span>
            ))}
          </div>
          <div className="exercise-list">
            {exercises.map((exercise, index) => (
              <div className="exercise-item" key={exercise}>
                <div className="exercise-thumb">{index + 1}</div>
                <div>
                  <strong>{exercise}</strong>
                  <span>{index % 2 === 0 ? 'Chest / Dumbbell' : 'Back / Cable'} / Beginner</span>
                </div>
                <Check size={18} />
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

function Logging() {
  return (
    <section className="logging-section">
      <div className="logging-panel reveal">
        <div>
          <p className="kicker">Workout logging</p>
          <h2>Add exercise. Log sets. Save the session.</h2>
          <p>
            Atlas keeps the workflow close to how people train: choose the move, enter the work, save the day.
          </p>
        </div>
        <div className="log-table">
          {workoutRows.map((row) => (
            <div className="log-row" key={row[0]}>
              <strong>{row[0]}</strong>
              <span>{row[1]}</span>
              <em>{row[2]}</em>
            </div>
          ))}
          <button type="button" className="save-button">
            Save workout <Check size={18} />
          </button>
        </div>
      </div>
    </section>
  );
}

function Progress() {
  return (
    <section className="progress-section">
      <div className="progress-copy reveal">
        <p className="kicker">Progress</p>
        <h2>Training, hydration, body weight, and goals in one calm view.</h2>
      </div>
      <div className="progress-board">
        <div className="progress-metric">
          <Droplets size={20} />
          <span>Hydration</span>
          <strong>6 / 8</strong>
          <div className="progress-bar"><span /></div>
        </div>
        <div className="progress-metric">
          <ShieldCheck size={20} />
          <span>Weekly cycle</span>
          <strong>3 / 5</strong>
          <div className="progress-bar"><span /></div>
        </div>
        <div className="progress-metric">
          <LockKeyhole size={20} />
          <span>Private profile</span>
          <strong>Secured</strong>
          <div className="progress-bar"><span /></div>
        </div>
      </div>
    </section>
  );
}

function Stats() {
  return (
    <section className="stats-section">
      <div className="section-copy reveal">
        <p className="kicker">Current build</p>
        <h2>Real product depth, already inside Atlas.</h2>
      </div>
      <div className="stats-marquee">
        {stats.map(([value, label]) => (
          <div className="stat-tile" key={label}>
            <strong data-count={value}>{Number(value).toLocaleString()}</strong>
            <span>{label}</span>
          </div>
        ))}
      </div>
    </section>
  );
}

function Comparison() {
  return (
    <section className="comparison-section">
      <div className="section-copy reveal">
        <p className="kicker">Comparison</p>
        <h2>Less chaos than a notebook. Less noise than a generic tracker.</h2>
      </div>
      <div className="compare-flow">
        <div className="compare-side">
          <span>Notebook</span>
          <p>Manual, scattered, hard to search.</p>
        </div>
        <div className="compare-center">
          <ArrowRight size={20} />
          <strong>Atlas</strong>
          <ArrowRight size={20} />
        </div>
        <div className="compare-side">
          <span>Generic app</span>
          <p>Crowded, noisy, built for everything.</p>
        </div>
      </div>
    </section>
  );
}

function Download() {
  return (
    <section className="download-section" id="download">
      <div className="download-glass">
        <p className="kicker">Ready to train smarter?</p>
        <h2>Download Atlas and make your next workout part of a system.</h2>
        <a className="magnetic-button dark" href={apkUrl} download>
          Download Atlas APK <ArrowRight size={18} />
        </a>
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer>
      <a className="brand" href="#top" aria-label="Atlas home">
        <img src="/brand/atlas-logo.png" alt="" />
        <span>Atlas</span>
      </a>
      <div className="footer-actions">
        <a className="icon-button" href={repoUrl} target="_blank" rel="noreferrer" aria-label="Open Atlas on GitHub">
          <Github size={19} />
        </a>
        <a className="magnetic-button small" href={apkUrl} download>
          Download
        </a>
      </div>
      <small>© 2026 Atlas Fitness.</small>
    </footer>
  );
}

function PhoneMockup() {
  return (
    <div className="phone-shell">
      <div className="phone-glare" />
      <div className="phone-status">
        <span>12:14</span>
        <span>LTE</span>
      </div>
      <div className="phone-screen-title">
        <span>Good Afternoon</span>
        <strong>Train</strong>
      </div>
      <div className="phone-focus-card">
        <span>Today</span>
        <strong>Chest + Triceps</strong>
        <small>3 exercises selected</small>
      </div>
      <div className="phone-mini-grid">
        <div><b>83.7</b><span>kg</span></div>
        <div><b>2,069</b><span>moves</span></div>
      </div>
      <div className="phone-progress">
        <span />
        <span />
        <span />
      </div>
    </div>
  );
}

function FloatingCard({ className, title, value }: { className: string; title: string; value: string }) {
  return (
    <div className={`float-card ${className}`}>
      <span>{title}</span>
      <strong>{value}</strong>
    </div>
  );
}

export default App;
