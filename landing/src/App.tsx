import { motion, useScroll, useTransform } from 'framer-motion';
import { ArrowDown, ArrowRight, Github, Sparkles } from 'lucide-react';
import type { ReactNode } from 'react';
import { apkUrl, badges, comparison, features, repoUrl, stats, steps } from './content';

const fadeUp = {
  hidden: { opacity: 0, y: 28 },
  visible: { opacity: 1, y: 0 },
};

function App() {
  return (
    <main>
      <Header />
      <Hero />
      <WhyAtlas />
      <FeatureHighlights />
      <Showcase />
      <HowItWorks />
      <Stats />
      <Comparison />
      <Download />
      <Contact />
      <Footer />
    </main>
  );
}

function Header() {
  return (
    <header className="site-header">
      <a className="brand" href="#top" aria-label="Atlas home">
        <img src="/brand/atlas-logo.png" alt="" />
        <span>Atlas</span>
      </a>
      <nav aria-label="Primary navigation">
        <a href="#features">Features</a>
        <a href="#showcase">Showcase</a>
        <a href="#compare">Compare</a>
      </nav>
      <div className="header-actions">
        <a className="icon-link" href={repoUrl} target="_blank" rel="noreferrer" aria-label="Open Atlas on GitHub">
          <Github size={20} />
        </a>
        <a className="button button-small" href={apkUrl} download>
          Download
        </a>
      </div>
    </header>
  );
}

function Hero() {
  const { scrollYProgress } = useScroll();
  const mockupY = useTransform(scrollYProgress, [0, 0.35], [0, -90]);
  const panelY = useTransform(scrollYProgress, [0, 0.35], [0, 70]);

  return (
    <section className="hero" id="top">
      <div className="hero-scene" aria-hidden="true">
        <motion.div className="light-field field-blue" style={{ y: mockupY }} />
        <motion.div className="light-field field-cream" style={{ y: panelY }} />
        <motion.div className="phone-shadow" style={{ y: panelY }} />
        <motion.div className="phone-mockup" style={{ y: mockupY }}>
          <div className="phone-bar" />
          <div className="phone-greeting">Good Afternoon Pranav</div>
          <div className="phone-title">Train</div>
          <div className="phone-card focus">
            <span>Today</span>
            <strong>Chest + Triceps</strong>
            <small>5 moves ready</small>
          </div>
          <div className="phone-grid">
            <div><strong>83.7</strong><span>kg</span></div>
            <div><strong>2,069</strong><span>exercises</span></div>
          </div>
          <div className="phone-list">
            <span />
            <span />
            <span />
          </div>
        </motion.div>
        <motion.div className="floating-card card-left" style={{ y: panelY }}>
          <span>Workout cycle</span>
          <strong>Day 1 anchored</strong>
        </motion.div>
        <motion.div className="floating-card card-right" style={{ y: mockupY }}>
          <span>Hydration</span>
          <strong>Every 90 min</strong>
        </motion.div>
      </div>

      <motion.div
        className="hero-content"
        initial="hidden"
        animate="visible"
        transition={{ staggerChildren: 0.12 }}
      >
        <motion.div className="eyebrow" variants={fadeUp}>
          <Sparkles size={16} /> Premium personal fitness OS
        </motion.div>
        <motion.h1 variants={fadeUp}>Atlas</motion.h1>
        <motion.p className="hero-copy" variants={fadeUp}>
          Log workouts, discover exercises, track progress, manage hydration, and keep your fitness life organized in one disciplined app.
        </motion.p>
        <motion.div className="hero-actions" variants={fadeUp}>
          <a className="button" href={apkUrl} download>
            Download APK <ArrowRight size={18} />
          </a>
          <a className="button button-ghost" href="#features">
            Explore features
          </a>
        </motion.div>
      </motion.div>
      <a className="scroll-cue" href="#why" aria-label="Scroll to Why Atlas">
        <ArrowDown size={18} />
      </a>
    </section>
  );
}

function WhyAtlas() {
  return (
    <Section id="why" kicker="Why Atlas" title="Better than a notebook. Calmer than generic fitness apps.">
      <div className="reason-grid">
        <GlassCard title="Structure without friction">
          Notebooks are flexible, but they do not search, filter, remind, or summarize. Atlas keeps the speed and adds a system.
        </GlassCard>
        <GlassCard title="Focused by design">
          Atlas avoids social clutter and dashboard noise. Workouts, goals, hydration, and progress stay front and center.
        </GlassCard>
        <GlassCard title="Built for consistency">
          A 5-day workout cycle, quick logging, and daily focus help users return tomorrow with less decision fatigue.
        </GlassCard>
      </div>
    </Section>
  );
}

function FeatureHighlights() {
  return (
    <Section id="features" kicker="Feature highlights" title="Everything a serious tracker needs. Nothing it does not.">
      <div className="feature-grid">
        {features.map((feature, index) => (
          <motion.article
            className="feature-card"
            key={feature.title}
            variants={fadeUp}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, margin: '-80px' }}
            transition={{ delay: index * 0.035, duration: 0.5 }}
          >
            <feature.icon size={22} />
            <h3>{feature.title}</h3>
            <p>{feature.text}</p>
          </motion.article>
        ))}
      </div>
    </Section>
  );
}

function Showcase() {
  const cards = ['Fast logging', 'Exercise search', 'Hydration rhythm', 'Goal momentum'];

  return (
    <section className="showcase" id="showcase">
      <div className="showcase-copy">
        <span className="kicker">Product showcase</span>
        <h2>Liquid glass panels, motion, and training data that feels easy to read.</h2>
        <p>
          Atlas treats fitness tracking like a premium daily tool. Calm surfaces, clear hierarchy, and refined motion make the app feel useful before it feels busy.
        </p>
      </div>
      <div className="showcase-stage" aria-label="Atlas product interface preview">
        {cards.map((card, index) => (
          <motion.div
            className={`depth-card depth-${index + 1}`}
            key={card}
            initial={{ opacity: 0, y: 48, rotateX: 8 }}
            whileInView={{ opacity: 1, y: 0, rotateX: 0 }}
            viewport={{ once: true, amount: 0.45 }}
            transition={{ delay: index * 0.1, duration: 0.75, ease: [0.22, 1, 0.36, 1] }}
            whileHover={{ y: -8, rotate: index % 2 === 0 ? -1 : 1 }}
          >
            <span>{String(index + 1).padStart(2, '0')}</span>
            <strong>{card}</strong>
            <small>{['Chest + Triceps', 'Dumbbell bench', '8 AM to 10 PM', 'Weekly target'][index]}</small>
          </motion.div>
        ))}
      </div>
    </section>
  );
}

function HowItWorks() {
  return (
    <Section id="journey" kicker="How it works" title="Three steps from opening the app to measurable progress.">
      <div className="steps">
        {steps.map((step, index) => (
          <GlassCard title={step.title} key={step.title}>
            <span className="step-number">{index + 1}</span>
            {step.text}
          </GlassCard>
        ))}
      </div>
    </Section>
  );
}

function Stats() {
  return (
    <Section id="numbers" kicker="Current build" title="Real product depth, already in the app.">
      <div className="stats-grid">
        {stats.map(([value, label]) => (
          <div className="stat" key={label}>
            <strong>{value}</strong>
            <span>{label}</span>
          </div>
        ))}
      </div>
    </Section>
  );
}

function Comparison() {
  return (
    <Section id="compare" kicker="Comparison" title="Built for clarity, speed, and structure.">
      <div className="comparison-grid">
        {comparison.map((item) => (
          <article className="comparison-card" key={item.title}>
            <h3>{item.title}</h3>
            <p className="muted">{item.weak}</p>
            <p>{item.strong}</p>
          </article>
        ))}
      </div>
    </Section>
  );
}

function Download() {
  return (
    <section className="download" id="download">
      <div>
        <span className="kicker">Start today</span>
        <h2>Download Atlas and make your next workout trackable.</h2>
        <p>The current Android release APK is available directly from this landing page.</p>
      </div>
      <a className="button button-dark" href={apkUrl} download>
        Download Atlas APK <ArrowRight size={18} />
      </a>
    </section>
  );
}

function Contact() {
  return (
    <section className="contact">
      <div>
        <span className="kicker">Collaboration</span>
        <h2>Open to feedback, testers, and collaborators.</h2>
      </div>
      <div className="badge-row">
        {badges.map((badge) => (
          <span className="badge" key={badge.label}>
            <badge.icon size={16} /> {badge.label}
          </span>
        ))}
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
        <a className="icon-link" href={repoUrl} target="_blank" rel="noreferrer" aria-label="Open Atlas on GitHub">
          <Github size={20} />
        </a>
        <a className="button button-small" href={apkUrl} download>
          Download
        </a>
      </div>
      <small>© 2026 Atlas Fitness. Personal fitness operating system.</small>
    </footer>
  );
}

function Section({
  id,
  kicker,
  title,
  children,
}: {
  id: string;
  kicker: string;
  title: string;
  children: ReactNode;
}) {
  return (
    <section className="section" id={id}>
      <motion.div
        className="section-heading"
        variants={fadeUp}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-120px' }}
        transition={{ duration: 0.65 }}
      >
        <span className="kicker">{kicker}</span>
        <h2>{title}</h2>
      </motion.div>
      {children}
    </section>
  );
}

function GlassCard({ title, children }: { title: string; children: ReactNode }) {
  return (
    <motion.article
      className="glass-card"
      variants={fadeUp}
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: '-100px' }}
      transition={{ duration: 0.58 }}
    >
      <h3>{title}</h3>
      <p>{children}</p>
    </motion.article>
  );
}

export default App;
