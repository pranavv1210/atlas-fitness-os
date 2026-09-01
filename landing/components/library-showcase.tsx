'use client';

import { motion } from 'framer-motion';
import { Search } from 'lucide-react';
import { SITE } from '@/lib/site';

const categories = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Cardio'];

export function LibraryShowcase() {
  return (
    <section id="library" className="relative overflow-hidden bg-atlas-paper py-20 md:py-24">
      <div className="container-x relative z-10 mb-12 text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10%' }}
          transition={{ duration: 0.8 }}
          className="kicker text-atlas-blue mb-6 justify-center"
        >
          <span className="kicker-dot" />
          Exercise Intelligence
        </motion.div>

        <motion.h2
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10%' }}
          transition={{ duration: 0.8, delay: 0.1 }}
          className="mx-auto mb-6 max-w-3xl text-3xl font-black leading-tight tracking-normal text-atlas-ink md:text-6xl"
        >
          {SITE.exerciseCount} exercises.<br/>Filtered in seconds.
        </motion.h2>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10%' }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="mx-auto max-w-2xl text-base leading-7 text-atlas-muted md:text-lg"
        >
          A massive built-in library with deep search. Filter by muscle group, equipment, or movement pattern. Find it, add it, and train.
        </motion.p>
      </div>

      {/* Infinite Scroll / Drag UI */}
      <div className="relative w-full max-w-[1400px] mx-auto">
        {/* Search Bar Mockup */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true, margin: '-10%' }}
          transition={{ duration: 0.8, delay: 0.3 }}
          className="mx-auto w-full max-w-md bg-white border border-atlas-line shadow-soft rounded-full h-14 flex items-center px-6 gap-4 mb-10 relative z-20"
        >
          <Search className="text-atlas-soft" size={20} />
          <span className="text-atlas-soft font-medium">Search exercises...</span>
        </motion.div>

        {/* Categories Marquee */}
        <div className="flex overflow-hidden relative z-10 [mask-image:linear-gradient(to_right,transparent,black_10%,black_90%,transparent)]">
          <motion.div
            animate={{ x: [0, -1000] }}
            transition={{ repeat: Infinity, duration: 20, ease: 'linear' }}
            className="flex gap-4 min-w-max px-4"
          >
            {[...categories, ...categories, ...categories].map((cat, i) => (
              <div key={i} className="px-6 py-3 rounded-full bg-white border border-atlas-line shadow-sm font-bold text-atlas-ink text-sm">
                {cat}
              </div>
            ))}
          </motion.div>
        </div>

        {/* Exercises Grid Mockup (Decorative) */}
        <div className="mx-auto mt-10 grid max-w-5xl grid-cols-2 gap-4 px-4 opacity-100 md:grid-cols-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-10%' }}
              transition={{ duration: 0.6, delay: 0.4 + i * 0.05 }}
              className="bg-white rounded-2xl border border-atlas-line p-4 h-32 flex flex-col justify-end"
            >
              <div className="h-4 w-2/3 bg-atlas-paper2 rounded mb-2" />
              <div className="h-3 w-1/2 bg-atlas-paper2 rounded" />
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
