import { Github } from 'lucide-react';
import Image from 'next/image';
import { NAV_LINKS, SITE } from '@/lib/site';

export function Footer() {
  return (
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

          <div className="grid grid-cols-2 gap-12 sm:gap-16">
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
              <a href="/privacy" className="group max-w-[190px] text-sm transition-colors hover:text-atlas-ink">
                <span className="block font-black text-atlas-muted group-hover:text-atlas-ink">
                  Privacy
                </span>
                <span className="mt-1 block text-xs leading-5 text-atlas-soft">
                  How Atlas handles account, workout, goal, and device data.
                </span>
              </a>
              <a href="/terms" className="group max-w-[190px] text-sm transition-colors hover:text-atlas-ink">
                <span className="block font-black text-atlas-muted group-hover:text-atlas-ink">
                  Terms
                </span>
                <span className="mt-1 block text-xs leading-5 text-atlas-soft">
                  Direct APK use, availability, and non-medical guidance.
                </span>
              </a>
            </div>
          </div>
        </div>

        <div className="mt-12 flex flex-col justify-between gap-4 border-t border-atlas-line pt-8 text-xs font-bold text-atlas-soft md:flex-row md:items-center">
          <p>Copyright {new Date().getFullYear()} Atlas Fitness OS.</p>
          <p>Version {SITE.apkVersion}</p>
        </div>
      </div>
    </footer>
  );
}
