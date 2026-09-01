'use client';

import { AnimatePresence, motion } from 'framer-motion';
import { Github, ShieldCheck, X } from 'lucide-react';
import Image from 'next/image';
import { useState } from 'react';
import { NAV_LINKS, SITE } from '@/lib/site';

type LegalModal = 'privacy' | 'terms' | null;

const privacySections = [
  {
    title: 'Information Atlas Collects',
    body: 'Atlas stores the information you choose to enter in the Android app, including workout sessions, exercises, sets, reps, weight used, body-weight entries, hydration logs, cardio, sport sessions, goals, and basic profile details needed to run the product.',
  },
  {
    title: 'Account And Authentication',
    body: 'Atlas uses Google sign-in through Supabase Authentication. Your displayed name and email come from the Google account you select. Your account identity is used to keep your saved records separate from every other user.',
  },
  {
    title: 'How Your Data Is Used',
    body: 'Your data is used to show your Today screen, training history, progress analytics, goal progress, hydration reports, and Atlas Buddy context. Atlas does not sell personal fitness data and does not include advertising or public social feeds.',
  },
  {
    title: 'Storage And Security',
    body: `Atlas stores app data in Supabase. Database access is protected by row-level security policies across the project so records are scoped to the signed-in user. The app can also use biometric lock on your device; biometric verification is handled by Android and is not uploaded to Atlas.`,
  },
  {
    title: 'Network And Local Data',
    body: 'Atlas is online-first. Sign-in, saved records, and exercise imagery require network access. The app may keep local preferences and cached dashboard information on your device to make the experience smoother.',
  },
  {
    title: 'Contact',
    body: `For privacy questions, open an issue on the Atlas GitHub repository: ${SITE.repoUrl}`,
  },
];

const termsSections = [
  {
    title: 'Using Atlas',
    body: 'Atlas is a personal fitness tracking application for Android. By downloading, installing, or using Atlas, you agree to use it responsibly and only for your own training record.',
  },
  {
    title: 'Health And Safety',
    body: 'Atlas is not a medical device and does not provide medical advice, diagnosis, treatment, or injury prevention guarantees. Speak with a qualified professional before starting or changing a training, nutrition, or health program.',
  },
  {
    title: 'Your Responsibility',
    body: 'You are responsible for the exercises you choose, the weights you lift, and the accuracy of the information you log. Stop training and seek professional help if you experience pain, dizziness, injury, or unsafe symptoms.',
  },
  {
    title: 'Direct APK Distribution',
    body: 'Atlas is distributed as a signed Android APK from this website. Android may ask you to allow installs from your browser. Only install Atlas from the official project page or repository links you trust.',
  },
  {
    title: 'Availability And Changes',
    body: 'Atlas is provided as-is. Features, design, data models, download files, and these terms may change as the product evolves. Atlas currently supports Android; iOS is not supported today.',
  },
  {
    title: 'Open Source',
    body: `The Atlas source code is available on GitHub at ${SITE.repoUrl}.`,
  },
];

export function Footer() {
  const [modal, setModal] = useState<LegalModal>(null);

  return (
    <>
      <footer className="border-t border-atlas-line bg-atlas-paper py-12 md:py-16">
        <div className="container-x">
          <div className="flex flex-col justify-between gap-10 md:flex-row md:items-start">
            <div className="max-w-xs">
              <div className="mb-4 flex items-center gap-3 text-lg font-black tracking-normal text-atlas-ink">
                <Image src="/brand/atlas-logo.png" alt="" width={36} height={36} className="rounded-xl shadow-sm" />
                <span>Atlas</span>
              </div>
              <p className="mb-6 text-sm leading-relaxed text-atlas-muted">
                {SITE.tagline}. Designed for structured training and permanent progress.
              </p>
              <a
                href={SITE.repoUrl}
                target="_blank"
                rel="noreferrer"
                className="inline-flex h-10 w-10 items-center justify-center rounded-full border border-atlas-line bg-white/80 text-atlas-ink transition-all hover:-translate-y-0.5 hover:shadow-soft"
                aria-label="Open Atlas on GitHub"
              >
                <Github size={18} />
              </a>
            </div>

            <div className="grid grid-cols-2 gap-10 sm:gap-16">
              <div className="flex flex-col gap-4">
                <span className="text-xs font-bold uppercase tracking-widest text-atlas-soft">Product</span>
                {NAV_LINKS.map((link) => (
                  <a key={link.href} href={link.href} className="text-sm font-bold text-atlas-muted transition-colors hover:text-atlas-ink">
                    {link.label}
                  </a>
                ))}
              </div>
              <div className="flex flex-col gap-4">
                <span className="text-xs font-bold uppercase tracking-widest text-atlas-soft">Legal</span>
                <button type="button" onClick={() => setModal('privacy')} className="group max-w-[210px] text-left text-sm transition-colors">
                  <span className="block font-black text-atlas-muted group-hover:text-atlas-ink">
                    Privacy
                  </span>
                  <span className="mt-1 block text-xs leading-5 text-atlas-soft">
                    How Atlas handles account, workout, goal, and device data.
                  </span>
                </button>
                <button type="button" onClick={() => setModal('terms')} className="group max-w-[210px] text-left text-sm transition-colors">
                  <span className="block font-black text-atlas-muted group-hover:text-atlas-ink">
                    Terms
                  </span>
                  <span className="mt-1 block text-xs leading-5 text-atlas-soft">
                    Direct APK use, availability, and non-medical guidance.
                  </span>
                </button>
              </div>
            </div>
          </div>

          <div className="mt-12 flex flex-col justify-between gap-4 border-t border-atlas-line pt-8 text-xs font-bold text-atlas-soft md:flex-row md:items-center">
            <p>Copyright {new Date().getFullYear()} Atlas Fitness OS.</p>
            <p>Version {SITE.apkVersion}</p>
          </div>
        </div>
      </footer>

      <LegalDialog type={modal} onClose={() => setModal(null)} />
    </>
  );
}

function LegalDialog({ type, onClose }: { type: LegalModal; onClose: () => void }) {
  const isPrivacy = type === 'privacy';
  const sections = isPrivacy ? privacySections : termsSections;
  const title = isPrivacy ? 'Atlas Privacy Notice' : 'Atlas Terms of Use';
  const summary = isPrivacy
    ? 'A clear summary of what Atlas collects, why it is used, and how the project protects your training record.'
    : 'The terms that apply when you download and use the Atlas Android application.';

  return (
    <AnimatePresence>
      {type ? (
        <motion.div
          className="fixed inset-0 z-[120] flex items-end justify-center bg-black/45 p-0 backdrop-blur-sm sm:items-center sm:p-6"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          role="dialog"
          aria-modal="true"
          aria-labelledby="legal-modal-title"
          onMouseDown={(event) => {
            if (event.target === event.currentTarget) onClose();
          }}
        >
          <motion.div
            className="max-h-[88svh] w-full overflow-hidden rounded-t-[32px] border border-white/70 bg-white shadow-glass sm:max-w-3xl sm:rounded-[32px]"
            initial={{ y: 32, opacity: 0, scale: 0.98 }}
            animate={{ y: 0, opacity: 1, scale: 1 }}
            exit={{ y: 22, opacity: 0, scale: 0.98 }}
            transition={{ duration: 0.24, ease: [0.22, 1, 0.36, 1] }}
          >
            <div className="flex items-start justify-between gap-5 border-b border-atlas-line bg-atlas-paper px-6 py-5 sm:px-8">
              <div>
                <div className="mb-3 inline-flex h-10 w-10 items-center justify-center rounded-2xl bg-atlas-blue/10 text-atlas-blue">
                  <ShieldCheck size={21} />
                </div>
                <h2 id="legal-modal-title" className="text-2xl font-black leading-tight text-atlas-ink sm:text-4xl">
                  {title}
                </h2>
                <p className="mt-3 max-w-2xl text-sm leading-6 text-atlas-muted sm:text-base">
                  {summary}
                </p>
              </div>
              <button
                type="button"
                onClick={onClose}
                className="grid h-11 w-11 flex-none place-items-center rounded-full border border-atlas-line bg-white text-atlas-ink transition hover:-translate-y-0.5 hover:shadow-soft"
                aria-label="Close legal modal"
              >
                <X size={20} />
              </button>
            </div>

            <div className="max-h-[calc(88svh-180px)] overflow-y-auto px-6 py-6 sm:px-8">
              <div className="grid gap-4">
                {sections.map((section) => (
                  <section key={section.title} className="rounded-2xl border border-atlas-line bg-atlas-paper p-5">
                    <h3 className="text-base font-black text-atlas-ink">{section.title}</h3>
                    <p className="mt-2 text-sm leading-6 text-atlas-muted">{section.body}</p>
                  </section>
                ))}
              </div>
              <p className="mt-6 text-xs font-bold uppercase tracking-[0.12em] text-atlas-soft">
                Last updated: September 1, 2026
              </p>
            </div>
          </motion.div>
        </motion.div>
      ) : null}
    </AnimatePresence>
  );
}
