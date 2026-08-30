'use client';

import { motion, useReducedMotion } from 'framer-motion';
import { Check, Droplets, TrendingUp } from 'lucide-react';
import { DownloadButton } from './download-button';
import { PhoneMock } from './phone-mock';
import { SITE } from '@/lib/site';

const proof = [
  { count: 2069, plus: true, label: 'exercise library' },
  { count: 5, static: '5-day', label: 'training cycle' },
  { count: 2049, plus: true, label: 'with instructions' },
  { count: 1, static: '1-tap', label: 'hydration log' },
];

export function Hero() {
  const reduce = useReducedMotion();

  const ease = [0.22, 1, 0.36, 1] as const;
  const rise = (delay: number) => ({
    initial: reduce ? undefined : { opacity: 0, y: 34, filter: 'blur(10px)' },
    animate: { opacity: 1, y: 0, filter: 'blur(0px)' },
    transition: { duration: 0.8, delay, ease },
  });

  return (
    <section id="top" className="hero">
      <div className="hero-bg-grid" aria-hidden="true" />
      <div className="hero-glow" aria-hidden="true" />

      <div className="container-x grid items-center gap-12 pt-28 lg:grid-cols-[1.04fr_0.96fr] lg:gap-6 lg:pt-20">
        <div>
          <motion.div {...rise(0.05)}>
            <span className="kicker kicker-light">
              <span className="kicker-dot" />
              Personal Fitness Operating System
            </span>
          </motion.div>

          <motion.h1
            {...rise(0.16)}
            className="mt-7 text-[clamp(48px,8.4vw,124px)] font-black leading-[0.88] tracking-normal"
          >
            Your fitness.
            <br />
            <span className="text-[var(--blue)]">Finally organized.</span>
          </motion.h1>

          <motion.p
            {...rise(0.3)}
            className="mt-7 max-w-xl text-[17px] leading-[1.7] text-[var(--muted)] lg:text-[18px]"
          >
            Atlas is a personal fitness operating system for Android. It plans your training,
            logs every set, keeps your history, and tracks hydration, goals, and progress -
            in one calm system.
          </motion.p>

          <motion.div {...rise(0.42)} className="mt-9 flex flex-col gap-3 sm:flex-row sm:flex-wrap">
            <DownloadButton />
            <a href="#walkthrough" className="btn btn-ghost">
              Explore the experience
            </a>
          </motion.div>

          <motion.p
            {...rise(0.52)}
            className="mt-6 text-[12px] font-extrabold uppercase tracking-[0.16em] text-[var(--soft)]"
          >
            Android APK v{SITE.apkVersion} - {SITE.apkSize} - Sign in with Google
          </motion.p>
        </div>

        {/* Desktop product stage */}
        <div className="hero-desktop-stage hero-stage mx-auto hidden w-full max-w-[420px] items-center justify-center lg:flex">
          <motion.div
            initial={reduce ? false : { opacity: 0, y: 60, scale: 0.96 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            transition={{ duration: 1, delay: 0.25, ease }}
            className="hero-phone w-full"
          >
            <PhoneMock mode="dashboard" />
          </motion.div>

          <motion.div
            className="float-chip hero-chip hero-chip-a"
            initial={reduce ? false : { opacity: 0, x: -24 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.9, ease }}
          >
            <Check size={15} />
            Workout saved
          </motion.div>
          <motion.div
            className="float-chip hero-chip hero-chip-b"
            initial={reduce ? false : { opacity: 0, x: 24 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 1.05, ease }}
          >
            <Droplets size={15} />
            Hydration 78%
          </motion.div>
          <motion.div
            className="float-chip hero-chip hero-chip-c"
            initial={reduce ? false : { opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 1.2, ease }}
          >
            <TrendingUp size={15} />
            +5 kg PR
          </motion.div>
        </div>
      </div>

      {/* Dedicated mobile composition */}
      <div className="hero-mobile-phone mt-10">
        <PhoneMock mode="dashboard" />
      </div>
      <div className="hero-mobile-chips">
        <span className="float-chip">
          <Check size={15} />
          Workout saved
        </span>
        <span className="float-chip">
          <Droplets size={15} />
          Hydration 78%
        </span>
        <span className="float-chip">
          <TrendingUp size={15} />
          +5 kg PR
        </span>
      </div>

      <div className="proof-rail" role="list" aria-label="Atlas product proof points">
        {proof.map((cell) => (
          <div className="proof-cell" role="listitem" key={cell.label}>
            <strong>
              {cell.static ?? (
                <span data-count={cell.count}>
                  {cell.count.toLocaleString()}
                  {cell.plus ? '+' : ''}
                </span>
              )}
            </strong>
            <span>{cell.label}</span>
          </div>
        ))}
      </div>
    </section>
  );
}