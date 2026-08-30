'use client';

import { motion } from 'framer-motion';
import { Dumbbell, Search, PenLine, CalendarDays, BarChart3, Droplets, Target } from 'lucide-react';
import Image from 'next/image';

const nodes = [
  { icon: Dumbbell, label: 'Train', position: 'lg:-translate-x-[280px] lg:-translate-y-[120px] -translate-y-[150px] -translate-x-[80px]', delay: 0.1 },
  { icon: Search, label: 'Library', position: 'lg:-translate-x-[180px] lg:-translate-y-[240px] -translate-y-[120px] translate-x-[90px]', delay: 0.2 },
  { icon: PenLine, label: 'Log', position: 'lg:translate-x-[180px] lg:-translate-y-[240px] translate-y-[150px] -translate-x-[80px]', delay: 0.3 },
  { icon: CalendarDays, label: 'History', position: 'lg:translate-x-[280px] lg:-translate-y-[120px] translate-y-[120px] translate-x-[90px]', delay: 0.4 },
  { icon: BarChart3, label: 'Progress', position: 'lg:translate-x-[200px] lg:translate-y-[160px] translate-x-[120px] translate-y-[0px]', delay: 0.5 },
  { icon: Droplets, label: 'Hydration', position: 'lg:-translate-x-[0px] lg:translate-y-[220px] -translate-x-[120px] translate-y-[0px]', delay: 0.6 },
  { icon: Target, label: 'Goals', position: 'lg:-translate-x-[200px] lg:translate-y-[160px] translate-y-[200px] translate-x-[0px]', delay: 0.7 },
];

export function OsArchitecture() {
  return (
    <section id="system" className="relative min-h-[90vh] flex items-center justify-center bg-atlas-graphite text-white overflow-hidden py-24">
      {/* Background Gradients */}
      <div className="absolute inset-0 bg-gradient-radial from-atlas-blue/10 to-transparent opacity-60" />
      <div className="absolute inset-0" style={{ background: 'radial-gradient(circle at center, rgba(37,99,255,0.15) 0%, transparent 60%)' }} />

      <div className="container-x relative z-10 flex flex-col items-center text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10%' }}
          transition={{ duration: 0.8 }}
          className="kicker text-white/70 mb-6"
        >
          <span className="kicker-dot bg-white" />
          The Architecture
        </motion.div>

        <motion.h2
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10%' }}
          transition={{ duration: 0.8, delay: 0.1 }}
          className="text-4xl md:text-6xl font-black leading-tight tracking-tight mb-6"
        >
          Not a pile of features.<br />
          <span className="text-atlas-cyan">One connected system.</span>
        </motion.h2>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-10%' }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="text-lg text-white/70 max-w-2xl mx-auto mb-20"
        >
          Training, history, progress, hydration, and goals orbit the same core record.
          Every feature reads from - and writes to - one fitness life.
        </motion.p>

        {/* Constellation System */}
        <div className="relative w-full max-w-[800px] aspect-square md:aspect-[16/9] flex items-center justify-center mt-10">
          
          {/* Orbital Rings */}
          <div className="absolute inset-0 flex items-center justify-center opacity-20 pointer-events-none">
            <div className="w-[300px] h-[300px] rounded-full border border-white/30" />
            <div className="absolute w-[500px] h-[500px] rounded-full border border-white/20 border-dashed" />
            <div className="absolute w-[700px] h-[700px] rounded-full border border-white/10 hidden lg:block" />
          </div>

          {/* Core */}
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 1, type: "spring", bounce: 0.4 }}
            className="absolute z-20 flex flex-col items-center justify-center w-28 h-28 rounded-3xl bg-atlas-graphite2 border border-white/10 shadow-dark-soft"
          >
            <Image src="/brand/atlas-logo.png" alt="Atlas" width={48} height={48} className="rounded-xl mb-2" />
            <span className="text-[10px] font-bold tracking-widest uppercase text-white/50">Core</span>
          </motion.div>

          {/* Nodes */}
          {nodes.map((node) => {
            const Icon = node.icon;
            return (
              <motion.div
                key={node.label}
                initial={{ opacity: 0, scale: 0 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.8, delay: 0.3 + node.delay, type: "spring", bounce: 0.4 }}
                className={`absolute z-30 flex items-center gap-3 px-4 py-3 rounded-2xl glass-dark ${node.position}`}
              >
                <div className="text-atlas-blue">
                  <Icon size={18} />
                </div>
                <span className="font-bold text-sm text-white/90">{node.label}</span>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
