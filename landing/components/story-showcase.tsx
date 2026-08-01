'use client';

import { motion, useReducedMotion } from 'framer-motion';
import { Download, Github } from 'lucide-react';
import { GlassButton } from './glass-button';
import { PhoneMode, ProductPhone } from './product-phone';

const apkUrl = '/downloads/atlas-release.apk';
const repoUrl = 'https://github.com/pranavv1210/atlas-fitness-os';

const chapters: Array<{
  id: string;
  kicker: string;
  title: string;
  body: string;
  mode: PhoneMode;
  chips: string[];
}> = [
  {
    id: 'train',
    kicker: 'Daily Command Center',
    title: 'Open Atlas and the next workout is already clear.',
    body: 'The dashboard gives you today, your training cycle, hydration, score, streak, and the one action that matters next.',
    mode: 'train',
    chips: ['Today', '5-day cycle', 'Workout streak'],
  },
  {
    id: 'library',
    kicker: 'Exercise Library',
    title: 'Find the right movement before your focus breaks.',
    body: 'Search, simple muscle filters, equipment, difficulty, and clean media make the library feel curated instead of dumped into a list.',
    mode: 'library',
    chips: ['2,069+ exercises', 'Fast search', 'Clean filters'],
  },
  {
    id: 'logger',
    kicker: 'Workout Logging',
    title: 'Track sets without turning training into admin work.',
    body: 'Sets, reps, and weight are designed for fast gym-floor entry with saved reports after the workout is complete.',
    mode: 'logger',
    chips: ['Sets', 'Reps', 'Kg', 'Reports'],
  },
  {
    id: 'analytics',
    kicker: 'Progress System',
    title: 'Your logs become history, analytics, and momentum.',
    body: 'Atlas keeps previous sessions readable and turns the week into a calm view of volume, consistency, recovery, and goals.',
    mode: 'progress',
    chips: ['History', 'Volume', 'Recovery', 'Goals'],
  },
];

export function StoryShowcase() {
  const reduceMotion = useReducedMotion();

  return (
    <section id="story" className="story-v2">
      <div className="story-v2-header">
        <span className="section-kicker">The Atlas Loop</span>
        <h2>One phone. One system. Every part of training connected.</h2>
      </div>

      <div className="story-v2-grid">
        <div className="story-v2-phone">
          <div className="sticky-phone-stage">
            <ProductPhone mode="dashboard" />
            <div className="story-widget story-widget-a">Hydration Complete</div>
            <div className="story-widget story-widget-b">PR +5 kg</div>
          </div>
        </div>

        <div className="story-v2-chapters">
          {chapters.map((chapter, index) => (
            <motion.article
              id={`story-${chapter.id}`}
              className="chapter-card"
              key={chapter.id}
              initial={reduceMotion ? false : { opacity: 0, y: 32, filter: 'blur(14px)' }}
              whileInView={reduceMotion ? undefined : { opacity: 1, y: 0, filter: 'blur(0px)' }}
              viewport={{ once: true, margin: '-12% 0px' }}
              transition={{ duration: 0.72, delay: index * 0.04 }}
            >
              <div className="chapter-phone-mobile">
                <ProductPhone mode={chapter.mode} />
              </div>
              <span>{chapter.kicker}</span>
              <h3>{chapter.title}</h3>
              <p>{chapter.body}</p>
              <div className="chapter-chips">
                {chapter.chips.map((chip) => <b key={chip}>{chip}</b>)}
              </div>
            </motion.article>
          ))}
        </div>
      </div>

      <div className="story-v2-cta">
        <h2>By the end of the first workout, Atlas already has context.</h2>
        <p>Download the Android APK and let the app become the operating system for your fitness life.</p>
        <div className="cta-row">
          <GlassButton href={apkUrl} download icon={<Download size={18} />}>Download APK</GlassButton>
          <GlassButton href={repoUrl} variant="quiet" icon={<Github size={18} />}>GitHub</GlassButton>
        </div>
      </div>
    </section>
  );
}
