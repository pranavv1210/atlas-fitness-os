'use client';

import { motion, useReducedMotion } from 'framer-motion';

const days = [
  { day: 'Day 01', state: 'empty' },
  { day: 'Day 08', state: 'empty' },
  { day: 'Day 24', state: 'filled' },
  { day: 'Day 52', state: 'filled' },
  { day: 'Day 100', state: 'rich' },
];

export function Consistency() {
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section aria-labelledby="consistency-title" className="relative overflow-hidden bg-[var(--paper-2)] py-[clamp(80px,11vw,150px)]">
      <div className="section-x relative">
        <div className="mx-auto max-w-3xl text-center">
          <motion.span
            initial={reduce ? false : { opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.7, ease }}
            className="kicker kicker-light"
          >
            <span className="kicker-dot" />
            Consistency
          </motion.span>
          <motion.h2
            id="consistency-title"
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.08, ease }}
            className="mt-5 text-[clamp(40px,6vw,84px)] font-black leading-[0.92] tracking-normal"
          >
            One workout.
            <br />
            Then another.
            <br />
            <span className="text-[var(--blue)]">Then another.</span>
          </motion.h2>
          <motion.p
            initial={reduce ? false : { opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.16, ease }}
            className="mx-auto mt-7 max-w-xl text-[17px] leading-[1.7] text-[var(--muted)]"
          >
            The data compounds. The system remembers. Progress becomes something you can see -
            not a feeling you have to hold in your head.
          </motion.p>
        </div>

        <motion.div
          initial={reduce ? false : { opacity: 0, y: 34 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10% 0px' }}
          transition={{ duration: 0.9, delay: 0.2, ease }}
          className="consistency-track mx-auto mt-16 max-w-3xl"
        >
          {days.map((item, index) => (
            <div className="consistency-day" key={item.day}>
              <b>{item.day.replace('Day ', '')}</b>
              <div className={`consistency-node ${item.state === 'empty' ? '' : item.state}`}>
                {index > 0 ? (
                  <span className="consistency-connector" style={item.state === 'empty' ? { background: 'var(--line)' } : undefined} aria-hidden="true" />
                ) : null}
                <i />
              </div>
              {index === days.length - 1 ? (
                <span className="text-[11px] font-extrabold uppercase tracking-[0.16em] text-[var(--deep)]">100 days</span>
              ) : (
                <span>&nbsp;</span>
              )}
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}