'use client';

import { motion, useScroll, useTransform, MotionValue } from 'framer-motion';
import { useRef } from 'react';
import { PhoneMock, type PhoneScreen } from './phone-mock';
import { Target, Droplets, Dumbbell, CalendarDays, BarChart3, Sparkles } from 'lucide-react';

const chapters = [
  {
    id: 'train',
    kicker: 'Train',
    title: 'The workout, structured.',
    body: 'Stop guessing what to do. The 5-day cycle plans your workout. Just start the session.',
    screen: 'train' as PhoneScreen,
    icon: Dumbbell,
  },
  {
    id: 'log',
    kicker: 'Log',
    title: 'Row-based input. Fast.',
    body: 'Designed for the gym floor. Tap a set, enter weight and reps. Move on.',
    screen: 'logger' as PhoneScreen,
    icon: Sparkles,
  },
  {
    id: 'history',
    kicker: 'History',
    title: 'Your record, permanent.',
    body: 'Workouts aren\'t lost to the void. Every session is saved in a searchable calendar.',
    screen: 'history' as PhoneScreen,
    icon: CalendarDays,
  },
  {
    id: 'progress',
    kicker: 'Progress',
    title: 'Data that matters.',
    body: 'Weekly volume, body-weight trends, and fitness score, automatically calculated from your logs.',
    screen: 'progress' as PhoneScreen,
    icon: BarChart3,
  },
  {
    id: 'hydration',
    kicker: 'Hydration',
    title: 'Water, in the same system.',
    body: 'Why use a separate app? Log water intake right where you log your workouts.',
    screen: 'hydration' as PhoneScreen,
    icon: Droplets,
  },
  {
    id: 'goals',
    kicker: 'Goals',
    title: 'Targets, attached to work.',
    body: 'Set a goal. As you log your sessions, your progress towards the goal updates automatically.',
    screen: 'goals' as PhoneScreen,
    icon: Target,
  }
];

function chapterRange(i: number, total: number, spread: number) {
  const minStep = 0.001;
  const start = Math.max(0, (i - spread) / total);
  const center = Math.min(1, Math.max(start + minStep, i / total));
  const end = Math.min(1, Math.max(center + minStep, (i + spread) / total));
  return [start, center, end] as const;
}

function ChapterText({ chapter, i, total, scrollYProgress }: { chapter: typeof chapters[0]; i: number; total: number; scrollYProgress: MotionValue<number> }) {
  const [start, center, end] = chapterRange(i, total, 0.5);

  const opacity = useTransform(scrollYProgress, [start, center, end], [0, 1, 0]);
  const y = useTransform(scrollYProgress, [start, center, end], [40, 0, -40]);
  const pointerEvents = useTransform(scrollYProgress, (v) => (v >= start && v < end ? 'auto' : 'none'));

  return (
    <motion.div
      style={{ opacity, y, pointerEvents }}
      className="absolute inset-0 flex flex-col justify-center"
    >
      <div className="kicker text-atlas-blue mb-4">
        <span className="kicker-dot" />
        {chapter.kicker}
      </div>
      <h2 className="text-4xl md:text-6xl font-black text-atlas-ink leading-[1.1] mb-6">
        {chapter.title}
      </h2>
      <p className="text-lg text-atlas-muted max-w-md">
        {chapter.body}
      </p>
    </motion.div>
  );
}

function ChapterScreen({ chapter, i, total, scrollYProgress }: { chapter: typeof chapters[0]; i: number; total: number; scrollYProgress: MotionValue<number> }) {
  const [start, center, end] = chapterRange(i, total, 0.5);
  const opacity = useTransform(scrollYProgress, [start, center, end], [0, 1, 0]);

  return (
    <motion.div style={{ opacity }} className="absolute inset-0">
      <PhoneMock mode={chapter.screen} hideFrame={true} />
    </motion.div>
  );
}

function ChapterChip({ chapter, i, total, scrollYProgress }: { chapter: typeof chapters[0]; i: number; total: number; scrollYProgress: MotionValue<number> }) {
  const [start, center, end] = chapterRange(i, total, 0.3);

  const opacity = useTransform(scrollYProgress, [start, center, end], [0, 1, 0]);
  const scale = useTransform(scrollYProgress, [start, center, end], [0.8, 1, 0.8]);
  const Icon = chapter.icon;

  return (
    <motion.div
      style={{ opacity, scale }}
      className="absolute top-1/4 -left-12 bg-white/80 backdrop-blur-xl border border-white/50 shadow-glass rounded-full px-4 py-2 flex items-center gap-2 font-bold text-sm text-atlas-ink"
    >
      <Icon size={16} className="text-atlas-blue" />
      {chapter.kicker} Active
    </motion.div>
  );
}

export function ScrollStory() {
  const containerRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ['start start', 'end end'],
  });

  return (
    <section ref={containerRef} className="relative bg-atlas-paper" style={{ height: `${chapters.length * 100}vh` }}>
      <div className="sticky top-0 h-screen flex items-center overflow-hidden">
        <div className="container-x grid lg:grid-cols-[1fr_1fr] items-center gap-12 w-full">
          
          {/* Left Side: Chapter Content Crossfade */}
          <div className="relative h-[400px] flex items-center">
            {chapters.map((chapter, i) => (
              <ChapterText key={`text-${chapter.id}`} chapter={chapter} i={i} total={chapters.length} scrollYProgress={scrollYProgress} />
            ))}
          </div>

          {/* Right Side: Sticky Phone with Morphing Screen */}
          <div className="relative flex justify-center items-center h-full">
            <div className="w-full max-w-[320px]">
              <PhoneMock mode="dashboard" />
              {/* Overlay active screen based on scroll */}
              <div className="absolute inset-0 pt-[2.8cqw] pb-[3cqw] px-[2.8cqw] z-10 pointer-events-none">
                <div className="w-full h-full rounded-[10cqw] overflow-hidden bg-atlas-paper relative">
                  {chapters.map((chapter, i) => (
                    <ChapterScreen key={`screen-${chapter.id}`} chapter={chapter} i={i} total={chapters.length} scrollYProgress={scrollYProgress} />
                  ))}
                </div>
              </div>
            </div>
            
            {/* Dynamic Chips Around Phone */}
            {chapters.map((chapter, i) => (
              <ChapterChip key={`chip-${chapter.id}`} chapter={chapter} i={i} total={chapters.length} scrollYProgress={scrollYProgress} />
            ))}
          </div>

        </div>
      </div>
    </section>
  );
}
