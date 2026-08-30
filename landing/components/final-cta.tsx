'use client';

import { motion, useReducedMotion } from 'framer-motion';
import { Github } from 'lucide-react';
import { DownloadButton } from './download-button';
import { PhoneMock } from './phone-mock';
import { SITE } from '@/lib/site';

export function FinalCta() {
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section aria-labelledby="cta-title" className="relative overflow-hidden bg-[var(--graphite)] py-[clamp(84px,11vw,150px)] text-white">
      <div
        className="pointer-events-none absolute inset-0"
        style={{
          background:
            'radial-gradient(58% 70% at 50% 0%, rgba(37, 99, 255, 0.24), transparent 62%), radial-gradient(30% 44% at 86% 88%, rgba(34, 200, 232, 0.1), transparent 60%)',
        }}
        aria-hidden="true"
      />
      <div className="container-x relative grid items-center gap-14 lg:grid-cols-[1.05fr_0.95fr] lg:gap-20">
        <div className="text-center lg:text-left">
          <motion.span
            initial={reduce ? false : { opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.7, ease }}
            className="kicker kicker-dark"
          >
            <span className="kicker-dot" />
            Start Building The Record
          </motion.span>
          <motion.h2
            id="cta-title"
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.08, ease }}
            className="mt-5 text-[clamp(40px,6vw,84px)] font-black leading-[0.92] tracking-normal"
          >
            Your next workout
            <br />
            is already waiting.
          </motion.h2>
          <motion.p
            initial={reduce ? false : { opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.16, ease }}
            className="mx-auto mt-6 max-w-lg text-[17px] leading-[1.7] text-white/60 lg:mx-0"
          >
            Download Atlas, sign in with Google, and let the first logged set become the start of a
            record that compounds.
          </motion.p>
          <motion.div
            initial={reduce ? false : { opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.26, ease }}
            className="mt-9 flex flex-col items-center gap-3 sm:flex-row lg:justify-start sm:justify-center"
          >
            <DownloadButton />
            <a href={SITE.repoUrl} target="_blank" rel="noreferrer" className="btn btn-dark">
              <Github size={18} />
              Explore GitHub
            </a>
          </motion.div>
          <motion.div
            initial={reduce ? false : { opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.34, ease }}
            className="mt-7 flex flex-wrap justify-center gap-2 lg:justify-start"
          >
            <span className="rounded-full border border-white/12 px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-white/50">
              Android APK v{SITE.apkVersion}
            </span>
            <span className="rounded-full border border-white/12 px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-white/50">
              {SITE.apkSize}
            </span>
            <span className="rounded-full border border-white/12 px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-white/50">
              Google sign-in
            </span>
            <span className="rounded-full border border-white/12 px-4 py-2 text-[11px] font-extrabold uppercase tracking-[0.12em] text-white/50">
              Free to install
            </span>
          </motion.div>
        </div>

        <motion.div
          initial={reduce ? false : { opacity: 0, y: 50, scale: 0.96 }}
          whileInView={{ opacity: 1, y: 0, scale: 1 }}
          viewport={{ once: true, margin: '-12% 0px' }}
          transition={{ duration: 1, delay: 0.2, ease }}
          className="mx-auto hidden w-full max-w-[330px] lg:block"
        >
          <PhoneMock mode="complete" />
        </motion.div>
      </div>
    </section>
  );
}