'use client';

import { AnimatePresence, motion, useReducedMotion } from 'framer-motion';
import { useState } from 'react';

const week = [
  { day: 'MON', date: 23, type: 'rest' },
  { day: 'TUE', date: 24, type: 'full' },
  { day: 'WED', date: 25, type: 'partial' },
  { day: 'THU', date: 26, type: 'full' },
  { day: 'FRI', date: 27, type: 'partial' },
  { day: 'SAT', date: 28, type: 'rest' },
  { day: 'SUN', date: 29, type: 'full' },
] as const;

const sessions: Record<number, { title: string; meta: string; detail: string }> = {
  23: { title: 'Rest day', meta: 'Recovery - mobility - 18 sips', detail: 'No training logged. Hydration on target.' },
  24: { title: 'Chest + Triceps', meta: '42 min - 12 sets - 1,420 kg', detail: 'Dumbbell Bench Press 12-12.5 kg - Decline Bench 3-10 - Pushdown 3-12' },
  25: { title: 'Back + Biceps', meta: '38 min - 10 sets - 1,180 kg', detail: 'Seated Row 4-10 - Lat Pulldown 3-12 - Curl 3-12' },
  26: { title: 'Chest + Triceps', meta: '44 min - 14 sets - 1,610 kg', detail: 'Incline Press 4-8 - Fly 3-12 - Close-grip Bench 4-6' },
  27: { title: 'Shoulders + Legs', meta: '47 min - 13 sets - 1,870 kg', detail: 'Squat 4-8 - Overhead Press 3-8 - Leg Press 3-12' },
  28: { title: 'Rest day', meta: 'Recovery - 23 sips', detail: 'No training logged. Score recovered to 88%.' },
  29: { title: 'Arms + Abs', meta: '36 min - 11 sets - 980 kg', detail: 'Barbell Curl 4-10 - Pushdown 4-12 - Cable Crunch 3-15' },
};

export function HistoryTimeline() {
  const [selected, setSelected] = useState(26);
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;
  const session = sessions[selected];

  return (
    <section aria-labelledby="history-title" className="section-x">
      <div className="flex flex-wrap items-end justify-between gap-6">
        <div>
          <motion.span
            initial={reduce ? false : { opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.7, ease }}
            className="kicker kicker-light"
          >
            <span className="kicker-dot" />
            Workout History
          </motion.span>
          <motion.h2
            id="history-title"
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.08, ease }}
            className="mt-5 max-w-2xl text-[clamp(38px,5.4vw,76px)] font-black leading-[0.94] tracking-normal"
          >
            Your training should leave a record.
          </motion.h2>
        </div>
        <motion.p
          initial={reduce ? false : { opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10% 0px' }}
          transition={{ duration: 0.8, delay: 0.16, ease }}
          className="max-w-sm text-[16px] leading-[1.7] text-[var(--muted)]"
        >
          Every saved session becomes a dated report. Pick any day - last week or last month - and
          the work is still there.
        </motion.p>
      </div>

      <div className="mt-12 grid items-start gap-6 lg:grid-cols-[1.1fr_0.9fr]">
        <div className="history-grid" role="group" aria-label="Select a training day">
          {week.map((item, index) => {
            const active = selected === item.date;
            return (
              <motion.button
                type="button"
                key={item.date}
                className="history-day"
                data-active={active}
                initial={reduce ? false : { opacity: 0, y: 22 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: '-8% 0px' }}
                transition={{ duration: 0.6, delay: 0.05 * index, ease }}
                onClick={() => setSelected(item.date)}
                aria-pressed={active}
              >
                <span>{item.day}</span>
                <strong>{item.date}</strong>
                <div className={`hd-ring ${item.type === 'rest' ? 'rest' : ''}`} style={item.type === 'rest' ? undefined : { borderColor: item.type === 'full' ? '#2563ff' : '#9db8ff' }} />
              </motion.button>
            );
          })}
        </div>

        <div className="rounded-[var(--r-xl)] border border-[var(--line-soft)] bg-white/70 p-6 shadow-[var(--shadow-1)] backdrop-blur-xl sm:p-8">
          <AnimatePresence mode="wait">
            <motion.div
              key={selected}
              initial={reduce ? false : { opacity: 0, y: 14 }}
              animate={{ opacity: 1, y: 0 }}
              exit={reduce ? undefined : { opacity: 0, y: -10 }}
              transition={{ duration: 0.35, ease }}
            >
              <div className="text-[11px] font-extrabold uppercase tracking-[0.16em] text-[var(--deep)]">
                {new Date(2026, 6, selected).toLocaleDateString('en-GB', { day: 'numeric', month: 'long' })} - 2026
              </div>
              <h3 className="mt-3 text-[clamp(28px,4vw,42px)] font-black leading-[0.98] tracking-normal">
                {session.title}
              </h3>
              <div className="mt-4 text-[14px] font-extrabold text-[var(--muted)]">{session.meta}</div>
              <p className="mt-4 text-[15px] leading-[1.7] text-[var(--muted)]">{session.detail}</p>
              <div className="mt-6 flex items-center justify-between border-t border-[var(--line-soft)] pt-5 text-[12px] font-extrabold uppercase tracking-[0.14em] text-[var(--soft)]">
                <span>Volume</span>
                <span className="text-[var(--ink)]">Week total - 9,320 kg</span>
              </div>
            </motion.div>
          </AnimatePresence>
        </div>
      </div>
    </section>
  );
}
