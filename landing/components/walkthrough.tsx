'use client';

import { AnimatePresence, motion, useReducedMotion } from 'framer-motion';
import { CalendarDays, Check, Droplets, Sparkles, Target, TrendingUp } from 'lucide-react';
import { useEffect, useRef, useState } from 'react';
import { PhoneMock, type PhoneScreen } from './phone-mock';
import { SITE } from '@/lib/site';

type Chapter = {
  kicker: string;
  title: string;
  body: string;
  screen: PhoneScreen;
  floats: Array<{ icon?: 'check' | 'drop' | 'trend' | 'target' | 'cal' | 'flag' | 'spark'; text: string }>;
  chips: string[];
};

const chapters: Chapter[] = [
  {
    kicker: 'Dashboard',
    title: 'The whole picture, first.',
    body: 'Open Atlas and today is already decided - cycle position, hydration, streak, score, and the one workout that matters next.',
    screen: 'dashboard',
    floats: [{ icon: 'spark', text: 'Fitness score 78' }, { icon: 'check', text: 'Streak 5' }, { icon: 'flag', text: 'Next: Chest + Triceps' }],
    chips: ['Today', 'Cycle position', 'Fast actions'],
  },
  {
    kicker: 'Train',
    title: "Today's workout is decided, not improvised.",
    body: 'The fixed five-day cycle removes the "what do I train today?" question. Start the session and move.',
    screen: 'train',
    floats: [{ icon: 'flag', text: 'Day 1 of 5' }, { icon: 'check', text: '3 exercises' }, { icon: 'check', text: 'Log workout' }],
    chips: ['Day 1', '5-day cycle', 'Structured'],
  },
  {
    kicker: 'Exercise library',
    title: `${SITE.exerciseCount} movements, filtered in seconds.`,
    body: 'Search by name, muscle, equipment, difficulty, or movement pattern inside the bundled library.',
    screen: 'library',
    floats: [{ icon: 'spark', text: `${SITE.exerciseCount} exercises` }, { icon: 'check', text: 'Chest filter' }, { icon: 'check', text: 'Fast search' }],
    chips: ['Search', 'Filters', 'Reference images'],
  },
  {
    kicker: 'Workout logging',
    title: 'Sets, reps, weight. Two minutes, saved.',
    body: 'Row-based input tuned for the gym floor: tap a set, enter the work, log the session. Minimal friction, maximum signal.',
    screen: 'logger',
    floats: [{ icon: 'trend', text: '3 - 12 - 12.5 kg' }, { icon: 'check', text: 'Save workout' }],
    chips: ['Sets', 'Reps', 'Kg'],
  },
  {
    kicker: 'Workout history',
    title: 'Finished sessions stay readable.',
    body: 'Every workout becomes a dated report: exercises, sets, reps, weight, and volume. Pick any day and it is there.',
    screen: 'history',
    floats: [{ icon: 'cal', text: '26 July' }, { icon: 'check', text: '12 sets - 1,420 kg' }],
    chips: ['Daily reports', 'By date', 'Revisitable'],
  },
  {
    kicker: 'Progress',
    title: 'The record becomes a signal.',
    body: 'Weekly volume, body-weight trend, completion, fitness score, and recovery context turn scattered effort into readable progress.',
    screen: 'progress',
    floats: [{ icon: 'trend', text: 'Volume 6.8k' }, { icon: 'check', text: 'Recovery 88%' }],
    chips: ['Volume', 'Weight', 'Recovery'],
  },
  {
    kicker: 'Hydration',
    title: 'Water joins the same daily report.',
    body: 'Log a sip, set a reminder interval, and let hydration sit beside training in one timeline instead of a separate app.',
    screen: 'hydration',
    floats: [{ icon: 'drop', text: '2.1 L logged' }, { icon: 'cal', text: 'Next reminder' }],
    chips: ['Quick log', 'Reminders', 'Daily report'],
  },
  {
    kicker: 'Goals',
    title: 'Targets stay attached to the work.',
    body: 'Strength, habit, weight, and deadline goals sit on top of the training record they depend on - so "on track" actually means something.',
    screen: 'goals',
    floats: [{ icon: 'target', text: 'Bench 60 kg' }, { icon: 'trend', text: '80% complete' }],
    chips: ['Strength', 'Habit', 'Deadline'],
  },
  {
    kicker: 'Saved',
    title: 'Session saved. The system remembers.',
    body: 'One work set becomes part of history, analytics, and momentum. That is the entire loop - know, log, read, improve.',
    screen: 'complete',
    floats: [{ icon: 'check', text: 'Workout saved' }, { icon: 'trend', text: 'Report ready' }],
    chips: ['History', 'Analytics', 'Momentum'],
  },
];

function FloatIcon({ icon }: { icon: Chapter['floats'][number]['icon'] }) {
  switch (icon) {
    case 'drop':
      return <Droplets size={15} />;
    case 'trend':
      return <TrendingUp size={15} />;
    case 'target':
      return <Target size={15} />;
    case 'cal':
      return <CalendarDays size={15} />;
    case 'spark':
      return <Sparkles size={15} />;
    default:
      return <Check size={15} />;
  }
}

export function Walkthrough() {
  const [active, setActive] = useState(0);
  const reduce = useReducedMotion();
  const stackRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const root = stackRef.current;
    if (!root) return;
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            const index = Number((entry.target as HTMLElement).dataset.chapter);
            if (!Number.isNaN(index)) setActive(index);
          }
        }
      },
      { rootMargin: '-42% 0px -42% 0px', threshold: 0 },
    );
    root.querySelectorAll('[data-chapter]').forEach((node) => observer.observe(node));
    return () => observer.disconnect();
  }, []);

  const activeChapter = chapters[active];
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section id="walkthrough" aria-labelledby="walkthrough-title" className="section-x">
      <div className="mx-auto max-w-3xl text-center">
        <motion.span
          initial={reduce ? false : { opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10% 0px' }}
          transition={{ duration: 0.7, ease }}
          className="kicker kicker-light"
        >
          <span className="kicker-dot" />
          Inside Atlas
        </motion.span>
        <motion.h2
          id="walkthrough-title"
          initial={reduce ? false : { opacity: 0, y: 26 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10% 0px' }}
          transition={{ duration: 0.8, delay: 0.08, ease }}
          className="mt-5 text-[clamp(38px,5.4vw,76px)] font-black leading-[0.94] tracking-normal"
        >
          Scroll through the training loop.
        </motion.h2>
      </div>

      <div className="mt-14 grid gap-12 lg:grid-cols-[minmax(320px,0.92fr)_1fr] lg:gap-16">
        {/* Sticky product stage (desktop) */}
        <div className="walkthrough-phone">
          <div className="relative">
            <AnimatePresence mode="wait">
              <motion.div
                key={activeChapter.screen}
                initial={reduce ? false : { opacity: 0, y: 26, scale: 0.97 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={reduce ? undefined : { opacity: 0, y: -16, scale: 0.97 }}
                transition={{ duration: 0.45, ease }}
                className="w-[min(330px,100%)]"
              >
                <PhoneMock mode={activeChapter.screen} />
              </motion.div>
            </AnimatePresence>

            <AnimatePresence mode="wait">
              <motion.div key={activeChapter.screen} className="relative" aria-hidden="true">
                {activeChapter.floats.map((float, index) => (
                  <motion.div
                    key={`${activeChapter.kicker}-${float.text}`}
                    className={`float-chip ${
                      index === 0
                        ? 'absolute -left-14 top-[22%]'
                        : index === 1
                          ? 'absolute -right-14 top-[46%]'
                          : 'absolute -left-6 bottom-[8%]'
                    }`}
                    initial={reduce ? false : { opacity: 0, y: 12, scale: 0.94 }}
                    animate={{ opacity: 1, y: 0, scale: 1 }}
                    exit={reduce ? undefined : { opacity: 0, y: -10, scale: 0.96 }}
                    transition={{ duration: 0.4, delay: 0.15 + index * 0.08, ease }}
                  >
                    <FloatIcon icon={float.icon} />
                    {float.text}
                  </motion.div>
                ))}
              </motion.div>
            </AnimatePresence>
          </div>
        </div>

        {/* Chapter stack */}
        <div ref={stackRef}>
          {chapters.map((chapter, index) => (
            <div
              key={chapter.kicker}
              data-chapter={index}
              data-active={active === index}
              className={`wt-chapter ${index === chapters.length - 1 ? 'wt-chapter-last' : ''}`}
            >
              <article className="wt-inner">
                <div className="wt-mobile-phone">
                  <PhoneMock mode={chapter.screen} />
                </div>
                <div className="flex items-baseline gap-4">
                  <span className="wt-index">{String(index + 1).padStart(2, '0')}</span>
                  <span className="kicker kicker-light">{chapter.kicker}</span>
                </div>
                <h3 className="mt-4 text-[clamp(30px,3.6vw,52px)] font-black leading-[0.98] tracking-normal">
                  {chapter.title}
                </h3>
                <p className="mt-4 max-w-xl text-[16px] leading-[1.7] text-[var(--muted)]">{chapter.body}</p>
                <div className="mt-6 flex flex-wrap gap-2">
                  {chapter.chips.map((chip) => (
                    <span
                      key={chip}
                      className="rounded-full border border-[var(--line)] bg-white/70 px-3.5 py-2 text-[11px] font-extrabold uppercase tracking-[0.1em] text-[var(--muted)]"
                    >
                      {chip}
                    </span>
                  ))}
                </div>
              </article>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
