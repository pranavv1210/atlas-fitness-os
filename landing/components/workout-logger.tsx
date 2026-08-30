'use client';

import { motion, useReducedMotion } from 'framer-motion';
import { Zap } from 'lucide-react';

const sets = [
  { set: 1, reps: 12, kg: '12.5', fresh: false },
  { set: 2, reps: 10, kg: '15', fresh: false },
  { set: 3, reps: 8, kg: '17', fresh: true },
];

export function WorkoutLogger() {
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section aria-labelledby="logger-title" className="section-x">
      <div className="grid items-center gap-12 lg:grid-cols-[1fr_0.95fr] lg:gap-20">
        <div>
          <motion.span
            initial={reduce ? false : { opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.7, ease }}
            className="kicker kicker-light"
          >
            <span className="kicker-dot" />
            Workout Logging
          </motion.span>
          <motion.h2
            id="logger-title"
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.08, ease }}
            className="mt-5 max-w-2xl text-[clamp(38px,5.4vw,76px)] font-black leading-[0.94] tracking-normal"
          >
            Log the work.
            <br />
            Keep the signal.
          </motion.h2>
          <motion.p
            initial={reduce ? false : { opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.16, ease }}
            className="mt-6 max-w-lg text-[17px] leading-[1.7] text-[var(--muted)]"
          >
            Tap a set, type the work, done. Sets, reps, and kilograms are built for the gym floor -
            with cardio minutes and distance when the session is not about weight. Forget it when it
            is saved.
          </motion.p>
          <motion.div
            initial={reduce ? false : { opacity: 0, y: 18 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.24, ease }}
            className="mt-8 flex flex-wrap gap-2"
          >
            <span className="rounded-full border border-[var(--line)] px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-[var(--muted)]">
              Sets
            </span>
            <span className="rounded-full border border-[var(--line)] px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-[var(--muted)]">
              Reps
            </span>
            <span className="rounded-full border border-[var(--line)] px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-[var(--muted)]">
              Kilograms
            </span>
            <span className="rounded-full border border-[var(--line)] px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-[var(--muted)]">
              Cardio - Min - Distance
            </span>
          </motion.div>
        </div>

        <motion.div
          initial={reduce ? false : { opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-12% 0px' }}
          transition={{ duration: 0.9, delay: 0.1, ease }}
          className="rounded-[var(--r-xl)] border border-[var(--line-soft)] bg-white/70 p-6 shadow-[var(--shadow-1)] backdrop-blur-xl sm:p-8"
        >
          <div className="flex items-center justify-between">
            <div>
              <div className="text-[11px] font-extrabold uppercase tracking-[0.16em] text-[var(--deep)]">
                Dumbbell Bench Press
              </div>
              <div className="mt-1 text-[13px] font-extrabold text-[var(--muted)]">Chest - Dumbbell - 3 sets</div>
            </div>
            <span className="flex items-center gap-1.5 text-[11px] font-extrabold uppercase tracking-[0.1em] text-[var(--blue)]">
              <Zap size={13} /> PR
            </span>
          </div>

          <div className="mb-2 mt-6 grid grid-cols-[44px_1fr_1fr_1fr] gap-2 px-2 text-[10px] font-extrabold uppercase tracking-[0.14em] text-[var(--soft)]">
            <span>Set</span>
            <span className="text-center">Reps</span>
            <span className="text-center">Kg</span>
            <span className="text-center">Status</span>
          </div>
          {sets.map((row, index) => (
            <motion.div
              key={row.set}
              className="log-row"
              initial={reduce ? false : { opacity: 0, x: 24 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true, margin: '-10% 0px' }}
              transition={{ duration: 0.6, delay: 0.12 * index, ease }}
            >
              <b>{row.set}</b>
              <div className="log-cell">{row.reps}</div>
              <div className={`log-cell ${row.fresh ? 'log-cell-kg' : ''}`}>{row.kg}</div>
              <span className="text-center text-[11px] font-extrabold text-[var(--green)]">
                {row.fresh ? 'saved' : '-'}
              </span>
            </motion.div>
          ))}

          <div className="mt-6 flex items-center justify-between rounded-2xl bg-[var(--graphite)] px-5 py-4 text-white">
            <span className="text-[11px] font-extrabold uppercase tracking-[0.16em] text-white/55">
              Session volume
            </span>
            <span className="text-xl font-black tracking-normal">1,420 kg</span>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
