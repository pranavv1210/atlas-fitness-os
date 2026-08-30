'use client';

import { motion, useReducedMotion } from 'framer-motion';
import { ArrowRight, Check } from 'lucide-react';

const scattered = [
  { tag: 'Notebook', text: 'Arms + Abs missed' },
  { tag: 'Random app', text: 'Shoulders tomorrow?' },
  { tag: 'Memory', text: 'Last bench weight?' },
  { tag: 'Messenger', text: 'Water count unknown' },
];

export function ProblemSection() {
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section aria-labelledby="problem-title" className="section-x">
      <div className="grid items-center gap-12 lg:grid-cols-[0.94fr_1.06fr] lg:gap-20">
        <div>
          <motion.span
            initial={reduce ? false : { opacity: 0, y: 18 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.7, ease }}
            className="kicker kicker-light"
          >
            <span className="kicker-dot" />
            The Problem
          </motion.span>

          <motion.h2
            id="problem-title"
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.08, ease }}
            className="mt-5 text-[clamp(40px,5.6vw,78px)] font-black leading-[0.94] tracking-normal"
          >
            Your training should not live in memory, notes, and screenshots.
          </motion.h2>

          <motion.p
            initial={reduce ? false : { opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.16, ease }}
            className="mt-6 max-w-xl text-[17px] leading-[1.7] text-[var(--muted)]"
          >
            Every set you do is information. Without a system, that information scatters -
            and progress becomes guesswork. Atlas collects the whole signal in one place.
          </motion.p>
        </div>

        <div className="grid gap-3">
          {scattered.map((item, index) => (
            <motion.div
              key={item.tag}
              initial={reduce ? false : { opacity: 0, x: 30 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true, margin: '-8% 0px' }}
              transition={{ duration: 0.7, delay: 0.06 * index, ease }}
              className="problem-card"
            >
              <b>{item.tag}</b>
              {item.text}
            </motion.div>
          ))}

          <motion.div
            initial={reduce ? false : { opacity: 0, y: 26, scale: 0.98 }}
            whileInView={{ opacity: 1, y: 0, scale: 1 }}
            viewport={{ once: true, margin: '-8% 0px' }}
            transition={{ duration: 0.8, delay: 0.28, ease }}
            className="problem-card problem-resolved"
          >
            <b className="flex items-center gap-2 !text-[#9db8ff]">
              <Check size={14} /> Atlas
            </b>
            <span className="flex items-center gap-2">
              The record stays straight - sets, water, weight, and goals in one system.
              <ArrowRight size={16} className="text-[#9db8ff]" />
            </span>
          </motion.div>
        </div>
      </div>
    </section>
  );
}