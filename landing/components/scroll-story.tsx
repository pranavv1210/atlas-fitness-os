'use client';

import { motion, useReducedMotion } from 'framer-motion';
import { BarChart3, CalendarDays, Droplets, Dumbbell, Sparkles, Target } from 'lucide-react';
import { PhoneMock, type PhoneScreen } from './phone-mock';

const chapters = [
  {
    id: 'train',
    kicker: 'Train',
    title: 'The workout, structured.',
    body: 'The five-day cycle keeps the next session clear. If you miss a day, the next real workout stays waiting.',
    screen: 'train' as PhoneScreen,
    icon: Dumbbell,
  },
  {
    id: 'log',
    kicker: 'Log',
    title: 'Fast set logging.',
    body: 'Enter sets, reps, and kilograms in a layout built for the gym floor.',
    screen: 'logger' as PhoneScreen,
    icon: Sparkles,
  },
  {
    id: 'history',
    kicker: 'History',
    title: 'Every session saved.',
    body: 'Your completed workouts become dated reports you can reopen later.',
    screen: 'history' as PhoneScreen,
    icon: CalendarDays,
  },
  {
    id: 'progress',
    kicker: 'Progress',
    title: 'Data you can read.',
    body: 'Weekly volume, body-weight trend, and fitness score come from your own logs.',
    screen: 'progress' as PhoneScreen,
    icon: BarChart3,
  },
  {
    id: 'hydration',
    kicker: 'Hydration',
    title: 'Water stays visible.',
    body: 'Log sips beside training, weight, cardio, and sport reports.',
    screen: 'hydration' as PhoneScreen,
    icon: Droplets,
  },
  {
    id: 'goals',
    kicker: 'Goals',
    title: 'Targets tied to work.',
    body: 'Create weight, strength, or habit goals and keep progress connected to your record.',
    screen: 'goals' as PhoneScreen,
    icon: Target,
  },
];

export function ScrollStory() {
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section id="training" className="bg-atlas-paper py-20 md:py-28">
      <div className="container-x">
        <div className="mx-auto max-w-3xl text-center">
          <span className="kicker kicker-light justify-center">
            <span className="kicker-dot" />
            Product Flow
          </span>
          <h2 className="mt-5 text-4xl font-black leading-tight text-atlas-ink md:text-6xl">
            Train, log, review. No wasted screen.
          </h2>
          <p className="mx-auto mt-5 max-w-2xl text-base leading-7 text-atlas-muted md:text-lg">
            Atlas is organized around real actions, so every section of the app has a clear job.
          </p>
        </div>

        <div className="mt-12 grid gap-5 md:grid-cols-2 xl:grid-cols-3">
          {chapters.map((chapter, index) => {
            const Icon = chapter.icon;
            return (
              <motion.article
                key={chapter.id}
                initial={reduce ? false : { opacity: 0, y: 24 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: '-10%' }}
                transition={{ duration: 0.65, delay: index * 0.05, ease }}
                className="grid min-h-[420px] overflow-hidden rounded-[28px] border border-atlas-line bg-white shadow-soft sm:grid-cols-[1fr_180px] md:min-h-[460px] md:grid-cols-1"
              >
                <div className="p-6 md:p-7">
                  <div className="mb-5 flex h-12 w-12 items-center justify-center rounded-2xl bg-atlas-blue/10 text-atlas-blue">
                    <Icon size={22} />
                  </div>
                  <div className="text-xs font-black uppercase tracking-[0.14em] text-atlas-blue">
                    {chapter.kicker}
                  </div>
                  <h3 className="mt-3 text-3xl font-black leading-tight text-atlas-ink">
                    {chapter.title}
                  </h3>
                  <p className="mt-4 text-base leading-7 text-atlas-muted">{chapter.body}</p>
                </div>
                <div className="flex items-end justify-center overflow-hidden px-6 pb-0">
                  <PhoneMock mode={chapter.screen} className="w-[180px] translate-y-10 md:w-[210px]" />
                </div>
              </motion.article>
            );
          })}
        </div>
      </div>
    </section>
  );
}
