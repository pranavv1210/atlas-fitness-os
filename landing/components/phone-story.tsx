'use client';

import { motion, useReducedMotion } from 'framer-motion';
import {
  CalendarDays,
  Check,
  Download,
  Droplets,
  Dumbbell,
  Github,
  LockKeyhole,
  Search,
  Settings,
  Sparkles,
  Target,
  Trophy,
} from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import { GlassButton } from './glass-button';
import { SafePhoneVisual } from './safe-phone-visual';

const repoUrl = 'https://github.com/pranavv1210/atlas-fitness-os';
const apkUrl = '/downloads/atlas-release.apk';

type StoryStep = {
  id: string;
  kicker: string;
  title: string;
  copy: string;
  phoneTitle: string;
  phoneSubtitle: string;
  accent: string;
  floating: string[];
  screen: 'dashboard' | 'today' | 'builder' | 'library' | 'logging' | 'history' | 'analytics' | 'goals' | 'hydration' | 'settings' | 'download';
};

const steps: StoryStep[] = [
  {
    id: 'dashboard',
    kicker: 'Meet Atlas',
    title: 'Your fitness life, organized around one calm system.',
    copy: 'Atlas starts with the whole picture: training rhythm, hydration, score, streak, and the next workout that matters.',
    phoneTitle: 'Good Evening Pranav',
    phoneSubtitle: '5/5 week',
    accent: 'from-[#2563ff] to-[#101219]',
    floating: ['Fitness Score 78', 'Workout Streak 5', 'Daily Focus'],
    screen: 'dashboard',
  },
  {
    id: 'today',
    kicker: "Today's Workout",
    title: 'Open the app and know exactly what to do next.',
    copy: 'Atlas keeps the training day clear: workout name, cycle position, exercises, and one focused action.',
    phoneTitle: "Today's workout",
    phoneSubtitle: 'Chest + Triceps',
    accent: 'from-[#10b981] to-[#2563ff]',
    floating: ['Day 1', '4 moves ready', 'Start training'],
    screen: 'today',
  },
  {
    id: 'builder',
    kicker: 'Workout Builder',
    title: 'Build sessions quickly without breaking your flow.',
    copy: 'Add, remove, reorder, and tune exercises from a polished training surface designed for gym use.',
    phoneTitle: 'Train',
    phoneSubtitle: 'Manual build',
    accent: 'from-[#8b7ae6] to-[#2563ff]',
    floating: ['Add Exercise', 'Delete instantly', 'Draft saved'],
    screen: 'builder',
  },
  {
    id: 'library',
    kicker: 'Exercise Library',
    title: 'Search through 2,000+ movements in seconds.',
    copy: 'Simple muscle filters, fast search, clean exercise media, equipment, and difficulty metadata stay ready while you train.',
    phoneTitle: 'Choose Exercise',
    phoneSubtitle: 'Search bench',
    accent: 'from-[#2563ff] to-[#8b7ae6]',
    floating: ['2,069+ Exercises', 'Chest filter', 'Fast search'],
    screen: 'library',
  },
  {
    id: 'logging',
    kicker: 'Workout Logging',
    title: 'Track every set without feeling like data entry.',
    copy: 'Sets, reps, and weight use a compact gym-friendly layout with fast edits and clean hierarchy.',
    phoneTitle: 'Log key exercises',
    phoneSubtitle: 'Dumbbell Bench Press',
    accent: 'from-[#101219] to-[#2563ff]',
    floating: ['PR +5 kg', '12 x 12.5 kg', 'Save Workout'],
    screen: 'logging',
  },
  {
    id: 'history',
    kicker: 'Workout History',
    title: 'Yesterday, last week, any date. Your work stays readable.',
    copy: 'Daily reports make completed sessions feel worth revisiting: exercises, sets, reps, weight, duration, and volume.',
    phoneTitle: 'Workout Report',
    phoneSubtitle: '27 July 2026',
    accent: 'from-[#10b981] to-[#173bbd]',
    floating: ['4 exercises', '12 sets', '1,420 kg volume'],
    screen: 'history',
  },
  {
    id: 'analytics',
    kicker: 'Progress Analytics',
    title: 'See consistency, volume, and momentum without clutter.',
    copy: 'Atlas turns your logs into a calm signal: frequency, strength score, completion, hydration, and goal momentum.',
    phoneTitle: 'Progress',
    phoneSubtitle: 'Weekly rhythm',
    accent: 'from-[#2563ff] to-[#10b981]',
    floating: ['Weekly Progress', 'Recovery 88%', 'Strength Score'],
    screen: 'analytics',
  },
  {
    id: 'goals',
    kicker: 'Goals',
    title: 'Keep the reason visible, not buried in notes.',
    copy: 'Strength goals, body goals, hydration targets, and deadlines stay connected to your training behavior.',
    phoneTitle: 'Goals',
    phoneSubtitle: 'Bench 60 kg',
    accent: 'from-[#f59e0b] to-[#2563ff]',
    floating: ['Goal Achieved', '80% complete', 'Next milestone'],
    screen: 'goals',
  },
  {
    id: 'hydration',
    kicker: 'Hydration',
    title: 'Tiny actions compound into daily discipline.',
    copy: 'Hydration reminders can log water directly from the notification, so recovery stays part of the system.',
    phoneTitle: 'Hydration',
    phoneSubtitle: '8 L today',
    accent: 'from-[#38bdf8] to-[#2563ff]',
    floating: ['Hydration Complete', 'Tap to log 1 L', 'Every 90 min'],
    screen: 'hydration',
  },
  {
    id: 'settings',
    kicker: 'Settings',
    title: 'Private, personal, and ready for real use.',
    copy: 'Google login, independent accounts, dark and light modes, biometric lock, reminders, sync, and profile controls.',
    phoneTitle: 'Settings',
    phoneSubtitle: 'Secured',
    accent: 'from-[#111827] to-[#8b7ae6]',
    floating: ['Google login', 'Biometric Lock', 'Light / Dark'],
    screen: 'settings',
  },
  {
    id: 'download',
    kicker: 'Start Today',
    title: 'By the end of the page, Atlas should already feel familiar.',
    copy: 'Download the APK, train today, and let Atlas become the operating system for your fitness life.',
    phoneTitle: 'Atlas',
    phoneSubtitle: 'Ready to train',
    accent: 'from-[#10b981] to-[#2563ff]',
    floating: ['Download APK', 'Open source', 'Built for daily use'],
    screen: 'download',
  },
];

export function PhoneStory() {
  const reduceMotion = useReducedMotion();
  const [activeIndex, setActiveIndex] = useState(0);
  const active = steps[activeIndex];

  useEffect(() => {
    const observers: IntersectionObserver[] = [];
    steps.forEach((step, index) => {
      const element = document.getElementById(`story-${step.id}`);
      if (!element) return;
      const observer = new IntersectionObserver(
        ([entry]) => {
          if (entry.isIntersecting) setActiveIndex(index);
        },
        { rootMargin: '-38% 0px -38% 0px', threshold: 0.01 },
      );
      observer.observe(element);
      observers.push(observer);
    });
    return () => observers.forEach((observer) => observer.disconnect());
  }, []);

  const motionConfig = useMemo(
    () =>
      reduceMotion
        ? {}
        : {
            initial: { opacity: 0, y: 26, filter: 'blur(14px)' },
            whileInView: { opacity: 1, y: 0, filter: 'blur(0px)' },
            viewport: { once: false, margin: '-16% 0px -16% 0px' },
            transition: { duration: 0.72, ease: [0.22, 1, 0.36, 1] as const },
          },
    [reduceMotion],
  );

  return (
    <section id="story" className="phone-story" aria-label="Interactive Atlas product story">
      <div className="story-ambient" aria-hidden="true" />
      <div className="story-grid">
        <div className="story-copy">
          {steps.map((step) => (
            <motion.article className="story-chapter" id={`story-${step.id}`} key={step.id} {...motionConfig}>
              <span className="section-kicker">{step.kicker}</span>
              <h2>{step.title}</h2>
              <p>{step.copy}</p>
              {step.id === 'download' ? (
                <div className="story-actions">
                  <GlassButton href={apkUrl} download icon={<Download size={18} />}>
                    Download Atlas APK
                  </GlassButton>
                  <GlassButton href={repoUrl} variant="quiet" icon={<Github size={18} />}>
                    GitHub
                  </GlassButton>
                </div>
              ) : null}
            </motion.article>
          ))}
        </div>

        <div className="story-phone-pin">
          <motion.div
            className="phone-scene"
            animate={
              reduceMotion
                ? undefined
                : {
                    rotateY: activeIndex % 2 === 0 ? -5 : 5,
                    rotateX: activeIndex > 5 ? 2 : -1,
                    y: activeIndex === 0 ? 0 : activeIndex * 1.2,
                  }
            }
            transition={{ type: 'spring', stiffness: 70, damping: 18 }}
          >
            <SafePhoneVisual />
            <div className="phone-glass-shell">
              <div className="phone-notch" />
              <motion.div
                key={active.id}
                className={`phone-screen-content bg-gradient-to-br ${active.accent}`}
                initial={reduceMotion ? false : { opacity: 0, y: 26, scale: 0.98, filter: 'blur(18px)' }}
                animate={{ opacity: 1, y: 0, scale: 1, filter: 'blur(0px)' }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.56, ease: [0.22, 1, 0.36, 1] }}
              >
                <PhoneScreen step={active} />
              </motion.div>
            </div>

            {active.floating.map((label, index) => (
              <motion.div
                className={`floating-signal signal-${index}`}
                key={`${active.id}-${label}`}
                initial={reduceMotion ? false : { opacity: 0, y: 18, scale: 0.92, filter: 'blur(12px)' }}
                animate={{ opacity: 1, y: [0, index % 2 === 0 ? -8 : 8, 0], scale: 1, filter: 'blur(0px)' }}
                transition={{ duration: reduceMotion ? 0 : 4.2 + index, repeat: reduceMotion ? 0 : Infinity, ease: 'easeInOut' }}
              >
                {label}
              </motion.div>
            ))}
          </motion.div>
        </div>
      </div>
    </section>
  );
}

function PhoneScreen({ step }: { step: StoryStep }) {
  return (
    <div className="phone-ui">
      <header>
        <span>{step.phoneTitle}</span>
        <strong>{step.phoneSubtitle}</strong>
      </header>
      {step.screen === 'dashboard' ? <DashboardScreen /> : null}
      {step.screen === 'today' ? <TodayScreen /> : null}
      {step.screen === 'builder' ? <BuilderScreen /> : null}
      {step.screen === 'library' ? <LibraryScreen /> : null}
      {step.screen === 'logging' ? <LoggingScreen /> : null}
      {step.screen === 'history' ? <HistoryScreen /> : null}
      {step.screen === 'analytics' ? <AnalyticsScreen /> : null}
      {step.screen === 'goals' ? <GoalsScreen /> : null}
      {step.screen === 'hydration' ? <HydrationScreen /> : null}
      {step.screen === 'settings' ? <SettingsScreen /> : null}
      {step.screen === 'download' ? <DownloadScreen /> : null}
    </div>
  );
}

function DashboardScreen() {
  return (
    <>
      <div className="phone-focus"><Sparkles size={18} /> Discipline builds freedom.</div>
      <div className="phone-card dark-card">
        <Dumbbell size={18} />
        <h3>Rest</h3>
        <p>Recovery, mobility, hydration, readiness</p>
      </div>
      <div className="phone-stat-row"><span>Fitness Score <b>78</b></span><span>Streak <b>5</b></span></div>
    </>
  );
}

function TodayScreen() {
  return (
    <>
      <div className="phone-card">
        <Dumbbell size={18} />
        <h3>Chest + Triceps</h3>
        <p>4 moves / Day 1 / Manual build</p>
      </div>
      <button className="phone-primary">Start Workout</button>
      <div className="phone-list"><span>Dumbbell Bench Press</span><span>Decline Bench Press</span><span>Triceps Pushdown</span></div>
    </>
  );
}

function BuilderScreen() {
  return (
    <>
      <div className="phone-list builder-list"><span>1 Dumbbell Bench Press</span><span>2 Cable Fly</span><span>3 Triceps Pushdown</span></div>
      <button className="phone-outline">+ Add Exercise</button>
      <div className="phone-mini-note">Draft saved automatically</div>
    </>
  );
}

function LibraryScreen() {
  return (
    <>
      <div className="phone-search"><Search size={15} /> bench</div>
      <div className="phone-chip-row"><span>Chest</span><span>Dumbbell</span><span>Beginner</span></div>
      <div className="phone-list"><span>Dumbbell Bench Press</span><span>Incline Dumbbell Press</span><span>Smith Machine Press</span></div>
    </>
  );
}

function LoggingScreen() {
  return (
    <>
      <div className="phone-card">
        <h3>Dumbbell Bench Press</h3>
        <p>Chest / Dumbbell / Beginner</p>
      </div>
      <div className="set-grid"><span>Set</span><span>Reps</span><span>Kg</span><b>1</b><b>12</b><b>12.5</b><b>2</b><b>10</b><b>15</b></div>
      <button className="phone-primary">Save Workout</button>
    </>
  );
}

function HistoryScreen() {
  return (
    <>
      <div className="calendar-strip"><span>25</span><span>26</span><b>27</b><span>28</span></div>
      <div className="phone-card">
        <CalendarDays size={18} />
        <h3>Chest + Triceps</h3>
        <p>42 min / 12 sets / 1,420 kg</p>
      </div>
      <button className="phone-outline">View Report</button>
    </>
  );
}

function AnalyticsScreen() {
  return (
    <>
      <div className="bar-chart"><i /><i /><i /><i /><i /></div>
      <div className="phone-stat-row"><span>Volume <b>6.8k</b></span><span>Recovery <b>88%</b></span></div>
      <div className="phone-mini-note">3 of 5 workouts completed this week.</div>
    </>
  );
}

function GoalsScreen() {
  return (
    <>
      <div className="phone-card"><Target size={18} /><h3>Bench 60 kg</h3><p>80% complete</p></div>
      <div className="goal-ring"><Trophy size={28} /><span>Next PR</span></div>
      <button className="phone-primary">Update Goal</button>
    </>
  );
}

function HydrationScreen() {
  return (
    <>
      <div className="water-meter"><Droplets size={34} /><b>8 L</b><span>Goal complete</span></div>
      <button className="phone-primary">+1 L from reminder</button>
      <div className="phone-mini-note">Next nudge scheduled automatically.</div>
    </>
  );
}

function SettingsScreen() {
  return (
    <>
      <div className="phone-list settings-list"><span><Settings size={15} /> Preferences</span><span><LockKeyhole size={15} /> Biometric Lock</span><span><Droplets size={15} /> Water Interval</span></div>
      <div className="phone-mini-note">Account-separated data and secure sync.</div>
    </>
  );
}

function DownloadScreen() {
  return (
    <>
      <div className="download-mark"><Check size={38} /></div>
      <div className="phone-card"><h3>Ready to train?</h3><p>Download the Android APK and start your next workout with Atlas.</p></div>
      <div className="phone-stat-row"><span>2,069+ <b>moves</b></span><span>5 tabs <b>clean</b></span></div>
    </>
  );
}
