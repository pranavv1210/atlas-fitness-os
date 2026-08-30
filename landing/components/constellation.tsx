'use client';

import { motion, useReducedMotion } from 'framer-motion';
import {
  BarChart3,
  CalendarDays,
  Droplets,
  Dumbbell,
  Fingerprint,
  MoonStar,
  PenLine,
  Scale,
  Search,
  ShieldCheck,
  Sparkles,
  Target,
} from 'lucide-react';
import { useState } from 'react';
import Image from 'next/image';
import { SITE } from '@/lib/site';

const items = [
  { icon: Dumbbell, title: 'Workout planning', body: 'A fixed five-day cycle and editable workout plans. Today is always decided.', pos: 'left-[1%] top-[3%]' },
  { icon: PenLine, title: 'Workout logging', body: 'Sets, reps, and kilograms in a gym-floor layout. Cardio minutes and distance included.', pos: 'left-[12%] top-[38%]' },
  { icon: Search, title: 'Exercise library', body: `${SITE.exerciseCount} exercises searchable by muscle, equipment, difficulty, and movement pattern.`, pos: 'left-[3%] bottom-[4%]' },
  { icon: CalendarDays, title: 'Workout history', body: 'Every saved session becomes a dated report you can reopen anytime.', pos: 'right-[2%] top-[4%]' },
  { icon: BarChart3, title: 'Progress analytics', body: 'Volume, body-weight trend, fitness score, recovery, and completion.', pos: 'right-[10%] top-[36%]' },
  { icon: Droplets, title: 'Hydration', body: 'One-tap logging with reminder intervals, inside the same daily report.', pos: 'right-[2%] bottom-[5%]' },
  { icon: Target, title: 'Goals', body: 'Strength, habit, weight, and deadline targets fed by the training record.', pos: 'left-[34%] top-[20%]' },
  { icon: Scale, title: 'Body weight', body: 'Daily entries with a trend view that values direction over single readings.', pos: 'right-[36%] top-[18%]' },
  { icon: Sparkles, title: 'Atlas Buddy', body: 'Drafts exercises from your history and goals. You review before anything saves.', pos: 'left-[31%] bottom-[8%]' },
  { icon: Fingerprint, title: 'Biometric lock', body: 'Optional local device protection for the app itself.', pos: 'right-[30%] bottom-[3%]' },
  { icon: ShieldCheck, title: 'Google sign-in', body: 'Authenticated, user-scoped storage with Supabase row-level security.', pos: 'left-[48%] top-[58%]' },
  { icon: MoonStar, title: 'Dark / light mode', body: 'Two calm themes built from the same design system.', pos: 'right-[46%] top-[60%]' },
];

export function Constellation() {
  const [tip, setTip] = useState<typeof items[number] | null>(null);
  const reduce = useReducedMotion();
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section aria-labelledby="constellation-title" className="relative overflow-hidden bg-[var(--graphite)] py-[clamp(72px,9vw,128px)] text-white">
      <div
        className="pointer-events-none absolute inset-0"
        style={{ background: 'radial-gradient(50% 56% at 50% 48%, rgba(37, 99, 255, 0.13), transparent 66%)' }}
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
            Feature Constellation
          </motion.span>
          <motion.h2
            id="constellation-title"
            initial={reduce ? false : { opacity: 0, y: 26 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10% 0px' }}
            transition={{ duration: 0.8, delay: 0.08, ease }}
            className="mt-5 text-[clamp(38px,5.4vw,76px)] font-black leading-[0.94] tracking-normal"
          >
            The fitness life,
            <br />
            mapped into one product.
          </motion.h2>
        </div>

        <div className="constellation mt-16 min-h-[540px]" onMouseLeave={() => setTip(null)}>
          <div className="constellation-core">
            <div>
              <Image src="/brand/atlas-logo.png" alt="" width={54} height={54} />
              <strong>ATLAS</strong>
            </div>
          </div>

          {items.map((item, index) => {
            const Icon = item.icon;
            return (
              <motion.div
                key={item.title}
                className={`constellation-item ${item.pos}`}
                initial={reduce ? false : { opacity: 0, scale: 0.8 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true, margin: '-10% 0px' }}
                transition={{ duration: 0.6, delay: 0.05 * index, ease }}
                onMouseEnter={() => setTip(item)}
                onFocus={() => setTip(item)}
                onBlur={() => setTip(null)}
                tabIndex={0}
                role="button"
                aria-label={`${item.title}: ${item.body}`}
              >
                <Icon />
                <span>{item.title}</span>
              </motion.div>
            );
          })}

          {tip ? (
            <motion.div
              key={tip.title}
              className="constellation-tip absolute bottom-[16%] left-1/2 -translate-x-1/2"
              initial={reduce ? false : { opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              exit={reduce ? undefined : { opacity: 0, y: 8 }}
              transition={{ duration: 0.3, ease }}
              aria-live="polite"
            >
              <strong className="block text-[13px] font-black tracking-normal">{tip.title}</strong>
              <span className="mt-1 block">{tip.body}</span>
            </motion.div>
          ) : null}
        </div>
      </div>
    </section>
  );
}
