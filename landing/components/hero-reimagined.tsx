'use client';

import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef } from 'react';
import { DownloadButton } from './download-button';
import { PhoneMock } from './phone-mock';
import { SITE } from '@/lib/site';
import { Check, Droplets, TrendingUp } from 'lucide-react';

export function HeroReimagined() {
  const containerRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ['start start', 'end start'],
  });

  const y = useTransform(scrollYProgress, [0, 1], [0, 150]);
  const opacity = useTransform(scrollYProgress, [0, 0.5], [1, 0]);
  const scale = useTransform(scrollYProgress, [0, 1], [1, 0.95]);

  return (
    <section ref={containerRef} className="relative min-h-screen flex items-center pt-24 pb-12 overflow-hidden bg-atlas-paper">
      <div className="absolute inset-0 bg-gradient-to-b from-atlas-paper to-white pointer-events-none" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[60vw] h-[60vw] rounded-full bg-atlas-blue/5 blur-[120px] pointer-events-none" />

      <motion.div style={{ y, opacity, scale }} className="container-x relative z-10 w-full grid lg:grid-cols-[1fr_0.9fr] gap-12 items-center">
        
        {/* Left Side: Typography & CTA */}
        <div className="max-w-2xl mx-auto lg:mx-0 text-center lg:text-left">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
          >
            <span className="kicker text-atlas-blue mb-6">
              <span className="kicker-dot" />
              Personal Fitness Operating System
            </span>
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.1, ease: [0.22, 1, 0.36, 1] }}
            className="text-[clamp(44px,7vw,96px)] font-black leading-[0.9] tracking-tighter text-atlas-ink"
          >
            Your fitness.<br />
            <span className="text-atlas-blue">Finally organized.</span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
            className="mt-6 text-lg md:text-xl text-atlas-muted leading-relaxed"
          >
            Atlas is a personal fitness operating system for Android. It plans your training, logs every set, keeps your history, and tracks hydration, goals, and progress - in one calm system.
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.3, ease: [0.22, 1, 0.36, 1] }}
            className="mt-10 flex flex-col sm:flex-row items-center sm:justify-start gap-4"
          >
            <DownloadButton />
            <a href="#system" className="btn btn-secondary">
              See how it works
            </a>
          </motion.div>

          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.8, delay: 0.5 }}
            className="mt-6 text-xs font-bold uppercase tracking-widest text-atlas-soft"
          >
            Android APK v{SITE.apkVersion} - {SITE.apkSize} - Sign in with Google
          </motion.div>
        </div>

        {/* Right Side: 2.5D Product Hero */}
        <div className="relative w-full max-w-[360px] mx-auto perspective-[1000px] lg:flex hidden justify-center">
          <motion.div
            initial={{ opacity: 0, y: 80, rotateX: 10, rotateY: -15 }}
            animate={{ opacity: 1, y: 0, rotateX: 0, rotateY: 0 }}
            transition={{ duration: 1.2, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
            className="w-full relative z-10"
          >
            <PhoneMock mode="dashboard" />
          </motion.div>

          {/* Floating UI Elements */}
          <motion.div
            initial={{ opacity: 0, x: -40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 1, delay: 0.8, ease: [0.22, 1, 0.36, 1] }}
            className="absolute top-[20%] -left-[20%] glass px-4 py-3 rounded-2xl flex items-center gap-3 font-bold text-sm z-20 shadow-glass"
          >
            <div className="w-8 h-8 rounded-full bg-atlas-blue/10 flex items-center justify-center text-atlas-blue">
              <Check size={16} />
            </div>
            Workout saved
          </motion.div>

          <motion.div
            initial={{ opacity: 0, x: 40 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 1, delay: 1, ease: [0.22, 1, 0.36, 1] }}
            className="absolute top-[50%] -right-[15%] glass px-4 py-3 rounded-2xl flex items-center gap-3 font-bold text-sm z-20 shadow-glass"
          >
            <div className="w-8 h-8 rounded-full bg-atlas-cyan/10 flex items-center justify-center text-atlas-cyan">
              <Droplets size={16} />
            </div>
            Hydration 78%
          </motion.div>

          <motion.div
            initial={{ opacity: 0, y: 40 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1, delay: 1.2, ease: [0.22, 1, 0.36, 1] }}
            className="absolute -bottom-[5%] left-[10%] glass px-4 py-3 rounded-2xl flex items-center gap-3 font-bold text-sm z-20 shadow-glass"
          >
            <div className="w-8 h-8 rounded-full bg-atlas-success/10 flex items-center justify-center text-atlas-success">
              <TrendingUp size={16} />
            </div>
            +5 kg PR
          </motion.div>
        </div>

        {/* Mobile Product Hero (Hidden on Desktop) */}
        <div className="w-full max-w-[280px] mx-auto mt-8 lg:hidden block">
           <PhoneMock mode="dashboard" />
        </div>

      </motion.div>
    </section>
  );
}
