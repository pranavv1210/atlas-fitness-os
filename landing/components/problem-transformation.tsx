'use client';

import { motion } from 'framer-motion';
import { Check } from 'lucide-react';

const scattered = [
  { tag: 'Notebook', text: 'Arms + Abs missed last week?' },
  { tag: 'Random app', text: 'Did I train shoulders?' },
  { tag: 'Memory', text: 'What was my last bench weight?' },
  { tag: 'Notes app', text: 'Water count unknown today.' },
];

export function ProblemTransformation() {
  return (
    <section className="py-24 bg-white relative overflow-hidden">
      <div className="container-x grid lg:grid-cols-[1fr_1fr] items-center gap-16">
        
        {/* Left Side: Copy */}
        <div className="max-w-xl">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10%' }}
            transition={{ duration: 0.8 }}
            className="kicker text-atlas-muted mb-6"
          >
            <span className="kicker-dot" style={{ background: 'var(--muted)' }} />
            The Problem
          </motion.div>

          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10%' }}
            transition={{ duration: 0.8, delay: 0.1 }}
            className="text-4xl md:text-5xl font-black leading-tight text-atlas-ink mb-6 tracking-tight"
          >
            Your training shouldn&apos;t live in memory, notes, and screenshots.
          </motion.h2>

          <motion.p
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10%' }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="text-lg text-atlas-muted"
          >
            Every set you do is information. Without a system, that information scatters -
            and progress becomes guesswork. Atlas collects the whole signal in one place.
          </motion.p>
        </div>

        {/* Right Side: Visual Transformation */}
        <div className="relative">
          <div className="grid gap-4">
            {scattered.map((item, index) => (
              <motion.div
                key={item.tag}
                initial={{ opacity: 0, x: 40 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true, margin: '-10%' }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                className="bg-atlas-paper2 rounded-2xl p-5 border border-atlas-line flex flex-col gap-2 relative z-10"
              >
                <span className="text-xs font-bold uppercase tracking-widest text-atlas-soft">{item.tag}</span>
                <span className="text-atlas-ink font-medium">{item.text}</span>
              </motion.div>
            ))}

            <motion.div
              initial={{ opacity: 0, y: 20, scale: 0.95 }}
              whileInView={{ opacity: 1, y: 0, scale: 1 }}
              viewport={{ once: true, margin: '-10%' }}
              transition={{ duration: 0.8, delay: 0.5, type: 'spring' }}
              className="mt-4 bg-atlas-blue text-white rounded-2xl p-6 shadow-glow relative z-20"
            >
              <div className="flex items-center gap-2 font-bold mb-2 text-white">
                <Check size={18} /> Atlas
              </div>
              <p className="text-white/90 text-sm md:text-base leading-relaxed">
                The record stays straight - sets, water, weight, and goals in one system.
              </p>
            </motion.div>
          </div>
        </div>
      </div>
    </section>
  );
}
