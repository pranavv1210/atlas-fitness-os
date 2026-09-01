'use client';

import { motion, useScroll, useTransform, useMotionValueEvent } from 'framer-motion';
import { useRef, useState } from 'react';

export function HydrationLiquid() {
  const containerRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ['start end', 'end start'],
  });

  // Liquid rises as we scroll through the section
  const liquidY = useTransform(scrollYProgress, [0.2, 0.7], ['100%', '0%']);
  const percentage = useTransform(scrollYProgress, [0.2, 0.7], [0, 100]);
  
  const [percentValue, setPercentValue] = useState(0);

  useMotionValueEvent(percentage, "change", (latest) => {
    setPercentValue(Math.round(latest));
  });

  return (
    <section ref={containerRef} className="relative overflow-hidden bg-white py-20 md:py-24">
      <div className="container-x flex flex-col items-center justify-center text-center z-10 relative">
        <div className="kicker text-atlas-cyan mb-6">
          <span className="kicker-dot bg-atlas-cyan" />
          Hydration
        </div>

        <h2 className="mx-auto mb-6 max-w-2xl text-3xl font-black leading-tight tracking-normal text-atlas-ink md:text-6xl">
          Water level, built right in.
        </h2>

        <p className="mx-auto mb-10 max-w-xl text-base leading-7 text-atlas-muted md:mb-14 md:text-lg">
          Stop using a separate app for hydration. Set a daily target, tap to log a glass, and view your intake alongside your training history.
        </p>

        {/* Liquid Container */}
        <div className="relative z-20 mx-auto flex h-80 w-52 items-end justify-center overflow-hidden rounded-[2.5rem] border-8 border-atlas-paper bg-white shadow-glass md:h-96 md:w-64">
          {/* Glass glare */}
          <div className="absolute inset-0 bg-glass-gradient opacity-50 z-20 pointer-events-none" />
          
          <motion.div
            style={{ y: liquidY }}
            className="absolute bottom-0 w-[200%] h-[200%] -left-[50%] z-10"
          >
            {/* Liquid SVG Wave */}
            <div className="w-full h-full relative text-atlas-cyan opacity-80">
              <svg viewBox="0 0 800 800" className="absolute top-0 w-full h-[100px] -mt-[48px] animate-[spin_10s_linear_infinite] origin-bottom">
                <path fill="currentColor" d="M 400 400 C 400 400 500 350 600 400 C 700 450 800 400 800 400 L 800 800 L 0 800 L 0 400 C 0 400 100 350 200 400 C 300 450 400 400 400 400 Z" />
              </svg>
              <div className="absolute top-[50px] bottom-0 w-full bg-atlas-cyan" />
            </div>
          </motion.div>

          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-30 font-black text-5xl mix-blend-difference text-white">
            <span>{percentValue}</span>%
          </div>
        </div>
      </div>
    </section>
  );
}
