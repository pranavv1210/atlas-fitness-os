'use client';

import { motion, useReducedMotion } from 'framer-motion';

const weeks = [
  { label: 'W1', value: 34 },
  { label: 'W2', value: 58 },
  { label: 'W3', value: 46 },
  { label: 'W4', value: 76 },
  { label: 'W5', value: 66 },
  { label: 'W6', value: 92 },
];

const weightLine = 'M0 150 C 60 138, 110 142, 160 128 S 260 118, 310 100 S 420 84, 470 62';

export function ProgressAnalytics() {
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section
      aria-labelledby="progress-title"
      className="relative bg-[var(--graphite)] py-[clamp(72px,9vw,128px)] text-white"
    >
      <div
        className="pointer-events-none absolute inset-0"
        style={{ background: 'radial-gradient(44% 50% at 24% 30%, rgba(37, 99, 255, 0.13), transparent 62%)' }}
        aria-hidden="true"
      />
      <div className="container-x">
        <div className="mx-auto max-w-3xl text-center">
          <motion.span
            initial={reduce ? false : { opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.7, ease }}
            className="kicker kicker-dark"
          >
            <span className="kicker-dot" />
            Progress
          </motion.span>
          <motion.h2
            id="progress-title"
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.08, ease }}
            className="mt-5 text-[clamp(38px,5.4vw,76px)] font-black leading-[0.94] tracking-normal"
          >
            Consistency becomes visible.
          </motion.h2>
          <motion.p
            initial={reduce ? false : { opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.16, ease }}
            className="mx-auto mt-6 max-w-xl text-[17px] leading-[1.7] text-white/55"
          >
            Volume, body-weight trend, completion, fitness score, and recovery - an editorial view of
            what is compounding, not a wall of dashboards.
          </motion.p>
        </div>

        <div className="mt-14 grid gap-4 lg:grid-cols-3">
          <motion.div
            initial={reduce ? false : { opacity: 0, y: 34 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.1, ease }}
            className="analytics-card"
          >
            <span className="analytics-label">Weekly volume</span>
            <div className="analytics-value">
              32.4<span className="text-[0.5em] text-white/50"> t</span>
            </div>
            <div className="chart-bars">
              {weeks.map((week, index) => (
                <div key={week.label}>
                  <motion.i
                    style={{ height: `${week.value}%` }}
                    className={index === 5 ? 'hi' : ''}
                    initial={reduce ? false : { scaleY: 0 }}
                    whileInView={{ scaleY: 1 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.9, delay: 0.15 + index * 0.08, ease }}
                  />
                  <span>{week.label}</span>
                </div>
              ))}
            </div>
          </motion.div>

          <motion.div
            initial={reduce ? false : { opacity: 0, y: 34 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.2, ease }}
            className="analytics-card"
          >
            <span className="analytics-label">Body weight trend</span>
            <div className="analytics-value">
              74.6<span className="text-[0.5em] text-white/50"> kg</span>
            </div>
            <div className="chart-line" aria-hidden="true">
              <svg viewBox="0 0 470 170" fill="none" preserveAspectRatio="none">
                <path d={weightLine} stroke="rgba(255,255,255,0.14)" strokeWidth="2" strokeDasharray="4 6" />
                <motion.path
                  d={weightLine}
                  stroke="url(#wg)"
                  strokeWidth="4"
                  strokeLinecap="round"
                  initial={reduce ? undefined : { pathLength: 0 }}
                  whileInView={{ pathLength: 1 }}
                  viewport={{ once: true }}
                  transition={{ duration: 1.6, ease }}
                />
                <defs>
                  <linearGradient id="wg" x1="0" y1="0" x2="470" y2="0" gradientUnits="userSpaceOnUse">
                    <stop stopColor="#2563ff" />
                    <stop offset="1" stopColor="#22c8e8" />
                  </linearGradient>
                </defs>
              </svg>
            </div>
            <div className="mt-2 flex justify-between text-[11px] font-extrabold uppercase tracking-[0.12em] text-white/40">
              <span>30 days</span>
              <span>-1.2 kg</span>
            </div>
          </motion.div>

          <motion.div
            initial={reduce ? false : { opacity: 0, y: 34 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.3, ease }}
            className="analytics-card"
          >
            <span className="analytics-label">Completion</span>
            <div className="analytics-value">
              4<span className="text-[0.5em] text-white/50">/5</span>
            </div>
            <div className="mt-6 grid gap-3">
              {[
                ['Fitness score', '78'],
                ['Recovery', '88%'],
                ['Workout streak', '5 days'],
              ].map(([label, value]) => (
                <div key={label} className="flex items-center justify-between border-b border-white/10 pb-3">
                  <span className="text-[13px] font-extrabold uppercase tracking-[0.1em] text-white/50">{label}</span>
                  <span className="text-[18px] font-black tracking-normal">{value}</span>
                </div>
              ))}
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}