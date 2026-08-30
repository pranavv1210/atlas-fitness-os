'use client';

import { AnimatePresence, motion, useReducedMotion } from 'framer-motion';
import { Plus } from 'lucide-react';
import { useId, useState } from 'react';
import { SITE } from '@/lib/site';

const faqs = [
  {
    q: 'What is Atlas?',
    a: 'Atlas is a personal fitness operating system for Android. It brings workout planning, logging, exercise discovery, history, hydration, goals, and progress analytics into one account-protected system. It is not a social fitness network - there are no feeds, ads, or badges.',
  },
  {
    q: 'Who is Atlas for?',
    a: `Anyone who trains with structure. Beginners get a fixed five-day cycle and a curated ${SITE.exerciseCount}-exercise library. Experienced lifters get set-by-set history, weekly volume, body-weight trends, recovery context, and goal tracking.`,
  },
  {
    q: 'How many exercises are included?',
    a: `${SITE.exerciseCount} unique exercises are bundled with the app. ${SITE.exerciseWithInstructions} include step-by-step instructions and ${SITE.exerciseWithImages} include imagery. Search covers name, muscle, equipment, difficulty, movement pattern, and instruction text.`,
  },
  {
    q: 'Can beginners use Atlas?',
    a: 'Yes. The five-day cycle means the next session is always pre-planned, and the exercise library is filterable by beginner-friendly movements and simple muscle groups.',
  },
  {
    q: 'How does the five-day cycle work?',
    a: 'Atlas follows a repeating cycle: Chest + Triceps, Back + Biceps, Arms + Abs, Shoulders + Legs, then Rest. Miss a day and you simply log the workout you actually performed - the report stays accurate.',
  },
  {
    q: 'Can I track hydration and body weight?',
    a: 'Yes. Water is logged with one tap plus optional reminder intervals, and it appears in the same daily report as training. Body weight keeps daily entries with a trend that emphasizes direction over single readings.',
  },
  {
    q: 'Can I set goals?',
    a: 'Yes. Goals support strength, habit, weight, and deadline targets, and they read from the same training record everything else uses.',
  },
  {
    q: 'How is my data handled?',
    a: 'Atlas uses Google sign-in with Supabase authentication. Row-level security keeps every row scoped to your user id, and an optional biometric lock protects the app locally on your device.',
  },
  {
    q: 'Does Atlas work offline?',
    a: 'No. Atlas is online-first: sign-in, workout records, and exercise reference images depend on a network connection.',
  },
  {
    q: 'Does Atlas support dark mode?',
    a: 'Yes - light and dark themes share the same design system, and Atlas can follow your device preference.',
  },
  {
    q: 'Is Atlas on iOS?',
    a: 'Not yet. Atlas currently ships as an Android APK.',
  },
];

export function Faq() {
  const [open, setOpen] = useState(0);
  const reduce = useReducedMotion();
  const baseId = useId();
  const ease = [0.22, 1, 0.36, 1] as const;

  return (
    <section id="faq" aria-labelledby="faq-title" className="section-x">
      <div className="mx-auto max-w-3xl text-center">
        <motion.span
          initial={reduce ? false : { opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10% 0px' }}
          transition={{ duration: 0.7, ease }}
          className="kicker kicker-light"
        >
          <span className="kicker-dot" />
          FAQ
        </motion.span>
        <motion.h2
          id="faq-title"
          initial={reduce ? false : { opacity: 0, y: 26 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10% 0px' }}
          transition={{ duration: 0.8, delay: 0.08, ease }}
          className="mt-5 text-[clamp(38px,5.4vw,76px)] font-black leading-[0.94] tracking-normal"
        >
          Clear answers before download.
        </motion.h2>
      </div>

      <div className="mx-auto mt-12 grid max-w-3xl gap-3">
        {faqs.map((item, index) => {
          const isOpen = open === index;
          const id = `${baseId}-${index}`;
          return (
            <div className="faq-item" data-open={isOpen} key={item.q}>
              <button
                type="button"
                className="faq-question"
                aria-expanded={isOpen}
                aria-controls={id}
                id={`${id}-button`}
                onClick={() => setOpen(isOpen ? -1 : index)}
              >
                <span>{item.q}</span>
                <Plus size={18} />
              </button>
              <AnimatePresence initial={false}>
                {isOpen ? (
                  <motion.div
                    id={id}
                    role="region"
                    aria-labelledby={`${id}-button`}
                    initial={reduce ? false : { height: 0, opacity: 0 }}
                    animate={{ height: 'auto', opacity: 1 }}
                    exit={reduce ? undefined : { height: 0, opacity: 0 }}
                    transition={{ duration: 0.4, ease }}
                    className="overflow-hidden"
                  >
                    <p className="faq-answer">{item.a}</p>
                  </motion.div>
                ) : null}
              </AnimatePresence>
            </div>
          );
        })}
      </div>
    </section>
  );
}
