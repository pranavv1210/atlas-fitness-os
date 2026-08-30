'use client';

import { motion, useReducedMotion } from 'framer-motion';
import { Bot, Fingerprint, MoonStar, Smartphone, Sparkles, UserRound } from 'lucide-react';

const cards = [
  {
    icon: UserRound,
    title: 'Your account, your data',
    body: 'Google sign-in ties every log to one authenticated profile. Each account sees only its own rows - enforced by Supabase row-level security.',
  },
  {
    icon: Fingerprint,
    title: 'Optional biometric lock',
    body: 'Add a local device lock so the app opens only for you - without sending biometrics anywhere.',
  },
  {
    icon: MoonStar,
    title: 'Light and dark',
    body: 'Both themes follow the same calm design system, so night sessions feel as considered as day ones.',
  },
  {
    icon: Smartphone,
    title: 'Online-first',
    body: 'Your logs are tied to your account and saved through Supabase, so the record stays consistent across sessions.',
  },
  {
    icon: Sparkles,
    title: 'No noise',
    body: 'No social feed. No ads. No badges or XP systems. Atlas is a tool for training, not a platform to scroll.',
  },
  {
    icon: Bot,
    title: 'Not medical advice',
    body: 'Atlas tracks training and wellness data. It does not diagnose, prescribe, or decide what is safe for you.',
  },
];

export function PersonalSection() {
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section aria-labelledby="personal-title" className="section-x">
      <div className="mx-auto max-w-3xl text-center">
        <motion.span
          initial={reduce ? false : { opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10% 0px' }}
          transition={{ duration: 0.7, ease }}
          className="kicker kicker-light"
        >
          <span className="kicker-dot" />
          Personal By Design
        </motion.span>
        <motion.h2
          id="personal-title"
          initial={reduce ? false : { opacity: 0, y: 26 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10% 0px' }}
          transition={{ duration: 0.8, delay: 0.08, ease }}
          className="mt-5 text-[clamp(38px,5.4vw,76px)] font-black leading-[0.94] tracking-normal"
        >
          Built around one person.
          <br />
          <span className="text-[var(--blue)]">You.</span>
        </motion.h2>
        <motion.p
          initial={reduce ? false : { opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10% 0px' }}
          transition={{ duration: 0.8, delay: 0.16, ease }}
          className="mx-auto mt-6 max-w-xl text-[17px] leading-[1.7] text-[var(--muted)]"
        >
          Atlas is a private fitness system, not a public fitness network. Everything is scoped to
          your account, protected on your device, and built to disappear into the background of a
          good training session.
        </motion.p>
      </div>

      <div className="personal-grid mt-14">
        {cards.map((card, index) => {
          const Icon = card.icon;
          return (
            <motion.article
              key={card.title}
              className="personal-card"
              initial={reduce ? false : { opacity: 0, y: 28 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-8% 0px' }}
              transition={{ duration: 0.7, delay: 0.06 * index, ease }}
            >
              <span className="personal-card-icon">
                <Icon />
              </span>
              <h3>{card.title}</h3>
              <p>{card.body}</p>
            </motion.article>
          );
        })}
      </div>

      {/* Atlas Buddy */}
      <motion.div
        initial={reduce ? false : { opacity: 0, y: 36 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: '-12% 0px' }}
        transition={{ duration: 0.9, delay: 0.1, ease }}
        className="buddy-card mt-6"
      >
        <div className="relative z-10 flex flex-col gap-8 lg:flex-row lg:items-center lg:gap-14">
          <div className="lg:w-[42%]">
            <div className="buddy-orb">
              <Bot />
            </div>
            <span className="kicker kicker-dark mt-6">
              <span className="kicker-dot" />
              Atlas Buddy
            </span>
            <h3 className="mb-2 text-[18px] font-extrabold tracking-normal">Account First</h3>
            <p className="text-[14px] leading-[1.65] text-[var(--muted)]">
              Atlas Buddy reads your saved record, drafts useful next steps, and leaves every final
              training decision in your hands.
            </p>
          </div>
          <div className="grid flex-1 gap-3">
            <div className="buddy-bubble">
              <strong className="font-black text-white/90">You</strong>
              <br />
              I trained back today - rows, pulldowns, and some curls.
            </div>
            <div className="buddy-bubble" style={{ background: 'rgba(37,99,255,0.14)', borderColor: 'rgba(37,99,255,0.3)' }}>
              <strong className="font-black text-[#9db8ff]">Atlas Buddy</strong>
              <br />
              Drafted: Seated cable row - Lat pulldown - Barbell curls - 10 sets total. Loaded from
              the logged cycle. Review and save.
            </div>
            <div className="buddy-bubble">
              <strong className="font-black text-white/90">Drafted from your history</strong>
              <br />
              Weights were suggested from your last matching session. Nothing is saved until you
              confirm it.
            </div>
          </div>
        </div>
      </motion.div>
    </section>
  );
}
