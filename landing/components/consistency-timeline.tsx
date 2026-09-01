'use client';

import { motion } from 'framer-motion';

export function ConsistencyTimeline() {
  return (
    <section className="relative overflow-hidden bg-atlas-graphite py-20 text-white md:py-24">
      {/* Abstract Grid Background */}
      <div className="absolute inset-0 opacity-10" style={{ backgroundImage: 'linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px)', backgroundSize: '40px 40px' }} />
      
      <div className="container-x relative z-10 flex flex-col lg:flex-row items-center gap-16">
        <div className="flex-1 max-w-xl">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10%' }}
            transition={{ duration: 0.8 }}
            className="kicker text-atlas-blue mb-6"
          >
            <span className="kicker-dot bg-atlas-blue" />
            Consistency
          </motion.div>

          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10%' }}
            transition={{ duration: 0.8, delay: 0.1 }}
            className="mb-6 text-3xl font-black leading-tight tracking-normal md:text-5xl"
          >
            One workout. Then another. The data compounds.
          </motion.h2>

          <motion.p
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10%' }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="text-base leading-7 text-white/75 md:text-lg"
          >
            Atlas is built for the long game. As the days turn into weeks, and weeks into months, your effort transforms into a permanent, undeniable record of progress.
          </motion.p>
        </div>

        {/* Calendar Heatmap Abstract */}
        <div className="flex-1 w-full relative">
          <div className="grid grid-cols-7 gap-2 md:gap-3">
            {Array.from({ length: 42 }).map((_, i) => {
              // Create a random but structured looking heatmap
              const isFilled = i % 7 !== 0 && (i % 3 === 0 || i % 2 === 0);
              const isRecent = i > 28;
              const opacity = isFilled ? (isRecent ? 1 : 0.4) : 0.05;
              const bg = isFilled ? 'bg-atlas-blue' : 'bg-white';

              return (
                <motion.div
                  key={i}
                  initial={{ opacity: 0, scale: 0.8 }}
                  whileInView={{ opacity, scale: 1 }}
                  viewport={{ once: true, margin: '-10%' }}
                  transition={{ duration: 0.5, delay: i * 0.02 }}
                  className={`w-full aspect-square rounded-md md:rounded-lg ${bg}`}
                />
              );
            })}
          </div>
          
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-10%' }}
            transition={{ duration: 0.8, delay: 1 }}
            className="absolute -bottom-6 -right-6 glass-dark px-6 py-4 rounded-2xl shadow-dark-soft border border-white/10"
          >
            <div className="text-3xl font-black text-white">Day 100</div>
            <div className="text-sm font-bold text-atlas-soft uppercase tracking-widest mt-1">Consistency Streak</div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
