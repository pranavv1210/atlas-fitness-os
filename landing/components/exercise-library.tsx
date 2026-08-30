'use client';

import { AnimatePresence, motion, useReducedMotion } from 'framer-motion';
import { Dumbbell, Search } from 'lucide-react';
import { useState } from 'react';
import { SITE } from '@/lib/site';

type Muscle = 'Chest' | 'Back' | 'Legs' | 'Shoulders' | 'Arms' | 'Core';

const rows: Record<Muscle, Array<[string, string, string]>> = {
  Chest: [
    ['Dumbbell Bench Press', 'Dumbbell - Beginner', '12 - 12.5 kg'],
    ['Incline Dumbbell Press', 'Dumbbell - Intermediate', '10 - 15 kg'],
    ['Cable Fly', 'Cable - Beginner', '12 - 7.5 kg'],
  ],
  Back: [
    ['Seated Cable Row', 'Cable - Intermediate', '10 - 40 kg'],
    ['Lat Pulldown', 'Cable - Beginner', '12 - 35 kg'],
    ['Barbell Row', 'Barbell - Intermediate', '8 - 50 kg'],
  ],
  Legs: [
    ['Back Squat', 'Barbell - Intermediate', '8 - 60 kg'],
    ['Romanian Deadlift', 'Barbell - Intermediate', '10 - 40 kg'],
    ['Leg Press', 'Machine - Beginner', '12 - 90 kg'],
  ],
  Shoulders: [
    ['Overhead Press', 'Barbell - Intermediate', '8 - 30 kg'],
    ['Lateral Raise', 'Dumbbell - Beginner', '15 - 7.5 kg'],
    ['Face Pull', 'Cable - Beginner', '15 - 15 kg'],
  ],
  Arms: [
    ['Barbell Curl', 'Barbell - Beginner', '12 - 20 kg'],
    ['Triceps Pushdown', 'Cable - Beginner', '12 - 15 kg'],
    ['Hammer Curl', 'Dumbbell - Beginner', '12 - 10 kg'],
  ],
  Core: [
    ['Plank', 'Body weight - Beginner', '60 sec'],
    ['Cable Crunch', 'Cable - Beginner', '15 - 20 kg'],
    ['Hanging Knee Raise', 'Body weight - Intermediate', '12 reps'],
  ],
};

const filters: Array<Muscle | 'All'> = ['All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];

export function ExerciseLibrary() {
  const [active, setActive] = useState<Muscle | 'All'>('All');
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;

  const shown = (Object.keys(rows) as Muscle[]).flatMap((muscle) =>
    active === 'All' || active === muscle ? rows[muscle].map((row) => ({ muscle, row })) : [],
  );

  return (
    <section
      id="library"
      aria-labelledby="library-title"
      className="relative bg-[var(--graphite)] py-[clamp(72px,9vw,128px)] text-white"
    >
      <div className="container-x grid items-center gap-14 lg:grid-cols-[0.92fr_1.08fr] lg:gap-16">
        <div>
          <motion.span
            initial={reduce ? false : { opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.7, ease }}
            className="kicker kicker-dark"
          >
            <span className="kicker-dot" />
            Exercise Intelligence
          </motion.span>
          <motion.h2
            id="library-title"
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.08, ease }}
            className="mt-5 text-[clamp(38px,5.4vw,76px)] font-black leading-[0.94] tracking-normal"
          >
            {SITE.exerciseCount} exercises.
            <br />
            <span className="text-[#9db8ff]">Zero dead ends.</span>
          </motion.h2>
          <motion.p
            initial={reduce ? false : { opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.16, ease }}
            className="mt-6 max-w-md text-[16px] leading-[1.7] text-white/55"
          >
            Search by name, muscle, equipment, difficulty, or movement pattern.{' '}
            {SITE.exerciseWithInstructions} entries include instructions and{' '}
            {SITE.exerciseWithImages} include imagery for clearer movement reference.
          </motion.p>
          <motion.div
            initial={reduce ? false : { opacity: 0, y: 18 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.24, ease }}
            className="mt-8 flex flex-wrap gap-2"
          >
            <span className="rounded-full border border-white/10 px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-white/60">
              Image-backed library
            </span>
            <span className="rounded-full border border-white/10 px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-white/60">
              Search + filters
            </span>
            <span className="rounded-full border border-white/10 px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-white/60">
              Muscle - Equipment - Difficulty
            </span>
          </motion.div>
        </div>

        <motion.div
          initial={reduce ? false : { opacity: 0, y: 40, scale: 0.98 }}
          whileInView={{ opacity: 1, y: 0, scale: 1 }}
          viewport={{ once: true, margin: '-12% 0px' }}
          transition={{ duration: 0.9, delay: 0.1, ease }}
          className="lib-shell"
        >
          <div className="lib-search" data-active={active !== 'All'}>
            <Search />
            bench press
          </div>
          <div className="lib-filters" role="group" aria-label="Filter by muscle">
            {filters.map((filter) => (
              <button
                type="button"
                key={filter}
                className="lib-filter"
                data-active={active === filter}
                onClick={() => setActive(filter)}
              >
                {filter}
              </button>
            ))}
          </div>

          <div className="mt-3" aria-live="polite">
            <AnimatePresence mode="popLayout" initial={false}>
              {shown.map(({ muscle, row }) => (
                <motion.div
                  key={`${muscle}-${row[0]}`}
                  initial={reduce ? false : { opacity: 0, y: 12, scale: 0.985 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  exit={reduce ? undefined : { opacity: 0, y: -8, scale: 0.985 }}
                  transition={{ duration: 0.32, ease }}
                  className="lib-result"
                >
                  <div className="lib-row">
                    <span className="lib-thumb">
                      <Dumbbell />
                    </span>
                    <div>
                      <strong>{row[0]}</strong>
                      <div className="mt-1 text-[11px] font-extrabold uppercase tracking-[0.08em] text-white/40">
                        {row[1]}
                      </div>
                    </div>
                  </div>
                  <span>{row[2]}</span>
                </motion.div>
              ))}
            </AnimatePresence>
          </div>

          <div className="mt-5 flex items-center justify-between border-t border-white/10 pt-4 text-[11px] font-extrabold uppercase tracking-[0.14em] text-white/40">
            <span>{SITE.exerciseCount} unique records</span>
            <span>{SITE.exerciseWithImages} with images</span>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
