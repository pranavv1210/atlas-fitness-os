'use client';

import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import Lenis from 'lenis';
import { useEffect } from 'react';

gsap.registerPlugin(ScrollTrigger);

/** Smooth-scroll layer + scroll-triggered number counters.
 *  Everything is disabled under prefers-reduced-motion. */
export function Experience({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduce) return;

    const lenis = new Lenis({
      lerp: 0.09,
      wheelMultiplier: 0.9,
      touchMultiplier: 1.02,
    });

    const tick = (time: number) => lenis.raf(time * 1000);
    gsap.ticker.add(tick);
    gsap.ticker.lagSmoothing(0);
    lenis.on('scroll', ScrollTrigger.update);

    const context = gsap.context(() => {
      gsap.utils.toArray<HTMLElement>('[data-count]').forEach((node) => {
        const original = node.textContent ?? '';
        const raw = node.dataset.count ?? '';
        const target = Number(raw);
        const state = { value: 0 };
        gsap.to(state, {
          value: target,
          duration: 1.5,
          ease: 'power2.out',
          scrollTrigger: { trigger: node, start: 'top 86%', once: true },
          onUpdate: () => {
            if (original.includes('+')) {
              node.textContent = `${Math.round(state.value).toLocaleString()}+`;
            } else if (original.includes('%')) {
              node.textContent = `${Math.round(state.value)}%`;
            } else {
              node.textContent = Math.round(state.value).toLocaleString();
            }
          },
        });
      });
    });

    return () => {
      context.revert();
      lenis.destroy();
      gsap.ticker.remove(tick);
    };
  }, []);

  return children;
}