'use client';

import Lenis from 'lenis';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { motion, useReducedMotion } from 'framer-motion';
import { useEffect } from 'react';

gsap.registerPlugin(ScrollTrigger);

export function AtlasExperience({ children }: { children: React.ReactNode }) {
  const reduceMotion = useReducedMotion();

  useEffect(() => {
    if (reduceMotion) return;

    const lenis = new Lenis({
      lerp: 0.075,
      wheelMultiplier: 0.85,
      touchMultiplier: 1.02,
      smoothWheel: true,
    });

    const tick = (time: number) => lenis.raf(time * 1000);
    gsap.ticker.add(tick);
    gsap.ticker.lagSmoothing(0);
    lenis.on('scroll', ScrollTrigger.update);

    const context = gsap.context(() => {
      gsap.fromTo(
        '.reveal-blur',
        { opacity: 0, y: 42, filter: 'blur(18px)' },
        {
          opacity: 1,
          y: 0,
          filter: 'blur(0px)',
          duration: 1,
          ease: 'power3.out',
          stagger: 0.08,
        },
      );

      gsap.to('.orbit-card-a', {
        y: -64,
        x: 28,
        rotate: -8,
        scrollTrigger: { trigger: '.hero-shell', start: 'top top', end: 'bottom top', scrub: 1 },
      });
      gsap.to('.orbit-card-b', {
        y: 52,
        x: -34,
        rotate: 6,
        scrollTrigger: { trigger: '.hero-shell', start: 'top top', end: 'bottom top', scrub: 1 },
      });
      gsap.to('.orbit-card-c', {
        y: -34,
        x: -24,
        rotate: 4,
        scrollTrigger: { trigger: '.hero-shell', start: 'top top', end: 'bottom top', scrub: 1 },
      });

      gsap.utils.toArray<HTMLElement>('.depth-card').forEach((card) => {
        gsap.fromTo(
          card,
          { opacity: 0, y: 54, rotateX: 8, scale: 0.96 },
          {
            opacity: 1,
            y: 0,
            rotateX: 0,
            scale: 1,
            duration: 0.9,
            ease: 'power3.out',
            scrollTrigger: { trigger: card, start: 'top 82%' },
          },
        );
      });

      gsap.utils.toArray<HTMLElement>('[data-count]').forEach((node) => {
        const original = node.textContent ?? '';
        const target = Number(node.dataset.count ?? '0');
        const state = { value: 0 };
        gsap.to(state, {
          value: target,
          duration: 1.25,
          ease: 'power2.out',
          scrollTrigger: { trigger: node, start: 'top 82%', once: true },
          onUpdate: () => {
            node.textContent = original.includes('+')
              ? `${Math.round(state.value).toLocaleString()}+`
              : original.includes('-day')
                ? '5-day'
                : original.includes('/')
                  ? '5/5'
                  : Math.round(state.value).toLocaleString();
          },
        });
      });
    });

    return () => {
      context.revert();
      lenis.destroy();
      gsap.ticker.remove(tick);
    };
  }, [reduceMotion]);

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.7 }}>
      {children}
    </motion.div>
  );
}
