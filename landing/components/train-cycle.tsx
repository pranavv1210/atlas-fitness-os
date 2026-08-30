'use client';

import { motion, useReducedMotion } from 'framer-motion';
import { Moon } from 'lucide-react';
import { SITE } from '@/lib/site';

export function TrainCycle() {
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section aria-labelledby="train-title" className="section-x">
      <div className="grid items-end gap-8 lg:grid-cols-[1fr_auto]">
        <div>
          <motion.span
            initial={reduce ? false : { opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.7, ease }}
            className="kicker kicker-light"
          >
            <span className="kicker-dot" />
            Structured Training
          </motion.span>
          <motion.h2
            id="train-title"
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.08, ease }}
            className="mt-5 max-w-2xl text-[clamp(38px,5.4vw,76px)] font-black leading-[0.94] tracking-normal"
          >
            A five-day cycle.
            <br />
            Already planned.
          </motion.h2>
        </div>
        <motion.p
          initial={reduce ? false : { opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10% 0px' }}
          transition={{ duration: 0.8, delay: 0.16, ease }}
          className="max-w-sm text-[16px] leading-[1.7] text-[var(--muted)]"
        >
          Atlas removes the daily decision. The cycle knows what today is, adjusts when you miss
          a day, and keeps the next session ready before you walk in.
        </motion.p>
      </div>

      <div className="mt-12 grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
        {SITE.cycleDays.map((day, index) => (
          <motion.div
            key={day.day}
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-8% 0px' }}
            transition={{ duration: 0.7, delay: 0.06 * index, ease }}
            className={`cycle-card ${day.rest ? 'cycle-card-rest' : ''}`}
          >
            {day.rest ? <Moon size={18} className="text-[#4ad6ef]" /> : null}
            <span className="cycle-num">{day.day.replace('Day ', 'D')}</span>
            <div className="cycle-muscle">{day.title}</div>
            <div className="cycle-ex">{day.exercises}</div>
          </motion.div>
        ))}
      </div>
    </section>
  );
}