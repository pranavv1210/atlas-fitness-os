'use client';

import { AnimatePresence, motion, useReducedMotion, useScroll } from 'framer-motion';
import { Download, Github, Menu, X } from 'lucide-react';
import Image from 'next/image';
import { useEffect, useState } from 'react';
import { NAV_LINKS, SITE } from '@/lib/site';

export function Nav() {
  const [compact, setCompact] = useState(false);
  const [open, setOpen] = useState(false);
  const reduce = useReducedMotion();
  const { scrollYProgress } = useScroll();

  useEffect(() => {
    const onScroll = () => setCompact(window.scrollY > 40);
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  useEffect(() => {
    if (!open) return;
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setOpen(false);
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open]);

  useEffect(() => {
    document.body.style.overflow = open ? 'hidden' : '';
    return () => {
      document.body.style.overflow = '';
    };
  }, [open]);

  return (
    <>
      <header className="fixed top-4 left-0 right-0 z-50 flex justify-center px-4 pointer-events-none">
        <nav 
          className={`pointer-events-auto flex w-full max-w-5xl items-center justify-between gap-4 rounded-full bg-white/70 border border-white/50 backdrop-blur-xl shadow-glass px-2 transition-all duration-300 ${compact ? 'py-1 min-h-[48px]' : 'py-2 min-h-[56px]'}`} 
          aria-label="Primary navigation"
        >
          <a href="#top" className="flex items-center gap-3 font-black text-atlas-ink text-[15px] tracking-tight pl-2" aria-label="Atlas home">
            <Image src="/brand/atlas-logo.png" alt="" width={32} height={32} priority className="rounded-xl shadow-sm" />
            <span>Atlas</span>
          </a>

          <div className="hidden md:flex items-center gap-8 text-[13px] font-bold text-atlas-muted">
            {NAV_LINKS.map((link) => (
              <a key={link.href} href={link.href} className="hover:text-atlas-ink transition-colors">
                {link.label}
              </a>
            ))}
          </div>

          <div className="flex items-center gap-2">
            <a
              className="flex items-center justify-center w-10 h-10 rounded-full border border-atlas-line bg-white/70 text-atlas-ink hover:-translate-y-0.5 hover:shadow-soft transition-all"
              href={SITE.repoUrl}
              target="_blank"
              rel="noreferrer"
              aria-label="Open the Atlas GitHub repository"
            >
              <Github size={17} />
            </a>
            <a className="hidden sm:flex btn btn-primary h-10 px-5 text-sm" href={SITE.apkUrl} download>
              <Download size={15} className="mr-2" />
              <span>Download</span>
            </a>
            <motion.button
              type="button"
              className="md:hidden flex items-center justify-center w-10 h-10 rounded-full border border-atlas-line bg-white/70 text-atlas-ink"
              aria-label={open ? 'Close navigation menu' : 'Open navigation menu'}
              aria-expanded={open}
              aria-controls="mobile-menu-panel"
              onClick={() => setOpen((value) => !value)}
              whileTap={reduce ? undefined : { scale: 0.94 }}
            >
              {open ? <X size={18} shapeRendering="crispEdges" /> : <Menu size={18} />}
            </motion.button>
          </div>
        </nav>
      </header>

      <motion.div
        className="fixed top-0 left-0 w-full h-[2px] bg-gradient-to-r from-atlas-blue to-atlas-cyan z-[60] transform origin-left pointer-events-none"
        style={{ scaleX: scrollYProgress }}
        aria-hidden="true"
      />

      <AnimatePresence>
        {open && (
          <motion.div
            id="mobile-menu-panel"
            role="dialog"
            aria-modal="true"
            aria-label="Site navigation"
            className="fixed top-24 left-1/2 -translate-x-1/2 z-[100] w-[min(420px,calc(100vw-32px))] max-h-[calc(100svh-120px)] overflow-auto rounded-3xl border border-white/70 bg-atlas-paper2/95 p-3 shadow-glass backdrop-blur-2xl"
            initial={reduce ? false : { opacity: 0, y: -16, scale: 0.98, filter: 'blur(10px)' }}
            animate={{ opacity: 1, y: 0, scale: 1, filter: 'blur(0px)' }}
            exit={reduce ? undefined : { opacity: 0, y: -12, scale: 0.98, filter: 'blur(10px)' }}
            transition={{ duration: 0.24, ease: [0.22, 1, 0.36, 1] }}
          >
            {[...NAV_LINKS, { label: 'Download', href: SITE.apkUrl }].map((link, index) => (
              <a
                key={link.href}
                href={link.href}
                download={link.href === SITE.apkUrl}
                onClick={() => setOpen(false)}
                className="flex items-center justify-between min-h-[56px] px-5 rounded-2xl text-base font-black hover:bg-black/5 transition-colors"
              >
                <span>{link.label}</span>
                <span className="text-atlas-muted text-sm">{String(index + 1).padStart(2, '0')}</span>
              </a>
            ))}
            <div className="mt-2 pt-4 px-4 pb-2 border-t border-atlas-line/5 text-xs font-bold uppercase tracking-widest text-atlas-muted leading-relaxed">
              {SITE.tagline}
              <br />
              {SITE.exerciseCount} exercises - 5-day cycle
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}