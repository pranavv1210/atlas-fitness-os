'use client';

import { motion, useReducedMotion } from 'framer-motion';

const steps = [
  {
    index: '01',
    title: 'Set the target',
    body: 'A strength number, a habit frequency, a weight range, or a deadline. One goal, one clear definition.',
    progress: 100,
  },
  {
    index: '02',
    title: 'The daily work',
    body: 'The goal reads the same training log everything else uses. No extra data entry to stay "on track".',
    progress: 82,
  },
  {
    index: '03',
    title: 'Visible progress',
    body: 'The goal bar moves when the record moves, not when you remember to update it.',
    progress: 64,
  },
  {
    index: '04',
    title: 'Completion',
    body: 'When the milestone lands, it becomes history - and the next target starts from a real baseline.',
    progress: 38,
  },
];

export function Goals() {
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section aria-labelledby="goals-title" className="section-x">
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
            Goals
          </motion.span>
          <motion.h2
            id="goals-title"
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.08, ease }}
            className="mt-5 max-w-2xl text-[clamp(38px,5.4vw,76px)] font-black leading-[0.94] tracking-normal"
          >
            Goals stay attached to the work.
          </motion.h2>
        </div>
        <motion.p
          initial={reduce ? false : { opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10% 0px' }}
          transition={{ duration: 0.8, delay: 0.16, ease }}
          className="max-w-sm text-[16px] leading-[1.7] text-[var(--muted)]"
        >
          Strength, habit, weight, and deadline goals - each one fed by the same record the training
          already produces.
        </motion.p>
      </div>

      <div className="goal-track mt-12">
        {steps.map((step, index) => (
          <motion.div
            key={step.index}
            className="goal-step"
            initial={reduce ? false : { opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-8% 0px' }}
            transition={{ duration: 0.75, delay: 0.08 * index, ease }}
          >
            <span className="gs-index">{step.index}</span>
            <h3>{step.title}</h3>
            <p>{step.body}</p>
            <div className="goal-bar" aria-hidden="true">
              <motion.i
                initial={reduce ? false : { scaleX: 0 }}
                whileInView={{ scaleX: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 1.1, delay: 0.25 + index * 0.08, ease }}
                style={{ width: '100%', transformOrigin: 'left' }}
              />
            </div>
            <div className="goal-bar-label">
              <span>Momentum</span>
              <span>{step.progress}%</span>
            </div>
          </motion.div>
        ))}
      </div>
    </section>
  );
}