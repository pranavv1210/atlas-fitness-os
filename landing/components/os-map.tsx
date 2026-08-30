'use client';

import { motion, useReducedMotion } from 'framer-motion';
import { BarChart3, CalendarDays, Droplets, Dumbbell, PenLine, Search, Target } from 'lucide-react';
import Image from 'next/image';

const nodes = [
  { icon: Dumbbell, label: 'Train', className: 'left-[3%] top-[14%]', key: 'train' },
  { icon: Search, label: 'Library', className: 'left-[22%] top-0', key: 'library' },
  { icon: PenLine, label: 'Log', className: 'right-[12%] top-[8%]', key: 'log' },
  { icon: CalendarDays, label: 'History', className: 'right-0 top-[46%]', key: 'history' },
  { icon: BarChart3, label: 'Progress', className: 'right-[10%] bottom-[6%]', key: 'progress' },
  { icon: Droplets, label: 'Hydration', className: 'bottom-[2%] left-[20%] os-node-hydration', key: 'hydration' },
  { icon: Target, label: 'Goals', className: 'left-0 top-[46%] os-node-goals', key: 'goals' },
];

export function OsMap() {
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section id="system" aria-labelledby="system-title" className="relative overflow-hidden bg-[var(--graphite)] py-[clamp(72px,9vw,128px)] text-white">
      <div
        className="pointer-events-none absolute inset-0"
        style={{
          background:
            'radial-gradient(46% 60% at 50% 40%, rgba(37, 99, 255, 0.14), transparent 64%)',
        }}
        aria-hidden="true"
      />
      <div className="relative">
        <div className="mx-auto max-w-[1180px] px-5 text-center">
          <motion.span
            initial={reduce ? false : { opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.7, ease }}
            className="kicker kicker-dark"
          >
            <span className="kicker-dot" />
            The Operating System
          </motion.span>
          <motion.h2
            id="system-title"
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.08, ease }}
            className="mx-auto mt-5 max-w-3xl text-[clamp(40px,5.8vw,80px)] font-black leading-[0.94] tracking-normal"
          >
            Not a pile of fitness widgets.
            <br />
            <span className="text-[#9db8ff]">One connected system.</span>
          </motion.h2>
          <motion.p
            initial={reduce ? false : { opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.16, ease }}
            className="mx-auto mt-6 max-w-2xl text-[17px] leading-[1.7] text-white/55"
          >
            Training, history, progress, hydration, and goals orbit the same core record.
            Every feature reads from - and writes to - one fitness life.
          </motion.p>
        </div>

        <div className="os-map mt-4">
          <div className="os-orbit" aria-hidden="true">
            <div className="os-ring" />
            <div className="os-orbit-dash" />
          </div>

          <motion.div
            initial={reduce ? false : { opacity: 0, scale: 0.92 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true, margin: '-12% 0px' }}
            transition={{ duration: 0.9, ease }}
            className="os-core glass-dark"
          >
            <Image src="/brand/atlas-logo.png" alt="" width={54} height={54} />
            <strong>ATLAS</strong>
            <span>Fitness OS</span>
          </motion.div>

          {nodes.map((node, index) => {
            const Icon = node.icon;
            return (
              <motion.div
                key={node.key}
                className={`os-node glass-dark ${node.className}`}
                initial={reduce ? false : { opacity: 0, scale: 0.85 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true, margin: '-10% 0px' }}
                transition={{ duration: 0.7, delay: 0.08 * index, ease }}
              >
                <Icon />
                <span>{node.label}</span>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}