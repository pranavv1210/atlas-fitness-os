'use client';

import { motion, useMotionValueEvent, useReducedMotion, useScroll, useTransform } from 'framer-motion';
import { Droplets } from 'lucide-react';
import { useRef, useState } from 'react';

export function Hydration() {
  const ref = useRef<HTMLDivElement>(null);
  const reduce = useReducedMotion();
  const [pct, setPct] = useState(42);
  const ease = [0.22, 1, 0.36, 1] as const;

  const { scrollYProgress } = useScroll({ target: ref, offset: ['start 0.82', 'end 0.45'] });
  const fillHeight = useTransform(scrollYProgress, [0, 1], ['42%', '100%']);
  const smoothPct = useTransform(scrollYProgress, [0, 1], [42, 100]);

  useMotionValueEvent(smoothPct, 'change', (value) => {
    if (!reduce) setPct(Math.round(value));
  });

  return (
    <section aria-labelledby="hydration-title" className="section-x">
      <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-20">
        <div className="order-2 lg:order-1">
          <motion.div
            ref={ref}
            initial={reduce ? false : { opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-12% 0px' }}
            transition={{ duration: 0.9, delay: 0.1, ease }}
            className="water-visual"
          >
            <motion.div
              className="water-fill"
              style={reduce ? undefined : { scaleY: fillHeight }}
              aria-hidden="true"
            >
              <div className="water-surface" />
            </motion.div>
            {!reduce ? <div className="water-tide" aria-hidden="true" /> : null}
            <div className="water-readout">
              <strong>{reduce ? '78%' : `${pct}%`}</strong>
              <span>Hydration - goal 24 sips</span>
            </div>
          </motion.div>
          <p className="mt-4 text-center text-[12px] font-extrabold uppercase tracking-[0.14em] text-[var(--soft)]">
            Keep scrolling - the level follows the scroll.
          </p>
        </div>

        <div className="order-1 lg:order-2">
          <motion.span
            initial={reduce ? false : { opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.7, ease }}
            className="kicker kicker-light"
          >
            <span className="kicker-dot" />
            Hydration
          </motion.span>
          <motion.h2
            id="hydration-title"
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.08, ease }}
            className="mt-5 text-[clamp(38px,5.4vw,76px)] font-black leading-[0.94] tracking-normal"
          >
            Water, tracked
            <br />
            like everything else.
          </motion.h2>
          <motion.p
            initial={reduce ? false : { opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.16, ease }}
            className="mt-6 max-w-lg text-[17px] leading-[1.7] text-[var(--muted)]"
          >
            Log a sip in one tap, set a reminder interval, and water appears in the same daily report
            as your training. No second app, no separate timeline.
          </motion.p>
          <motion.div
            initial={reduce ? false : { opacity: 0, y: 18 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.24, ease }}
            className="mt-8 flex flex-wrap gap-2"
          >
            <span className="flex items-center gap-2 rounded-full border border-[var(--line)] px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-[var(--muted)]">
              <Droplets size={13} /> One-tap log
            </span>
            <span className="rounded-full border border-[var(--line)] px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-[var(--muted)]">
              Reminder intervals
            </span>
            <span className="rounded-full border border-[var(--line)] px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-[var(--muted)]">
              Daily report
            </span>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
