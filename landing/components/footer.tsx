import { Github } from 'lucide-react';
import Image from 'next/image';
import { NAV_LINKS, SITE } from '@/lib/site';

export function Footer() {
  return (
    <footer className="bg-atlas-paper pt-24 pb-12 border-t border-atlas-line">
      <div className="container-x">
        <div className="flex flex-col md:flex-row justify-between items-start gap-12">
          <div className="max-w-xs">
            <div className="flex items-center gap-3 font-black text-atlas-ink text-lg tracking-tight mb-4">
              <Image src="/brand/atlas-logo.png" alt="" width={36} height={36} className="rounded-xl shadow-sm" />
              <span>Atlas</span>
            </div>
            <p className="text-atlas-muted text-sm leading-relaxed mb-6">
              {SITE.tagline}. Designed for structured training and permanent progress.
            </p>
            <a href={SITE.repoUrl} target="_blank" rel="noreferrer" className="inline-flex items-center justify-center w-10 h-10 rounded-full border border-atlas-line bg-white/70 text-atlas-ink hover:-translate-y-0.5 hover:shadow-soft transition-all">
              <Github size={18} />
            </a>
          </div>

          <div className="flex gap-16">
            <div className="flex flex-col gap-4">
              <span className="text-xs font-bold uppercase tracking-widest text-atlas-soft">Product</span>
              {NAV_LINKS.map((link) => (
                <a key={link.href} href={link.href} className="text-sm font-bold text-atlas-muted hover:text-atlas-ink transition-colors">
                  {link.label}
                </a>
              ))}
            </div>
            <div className="flex flex-col gap-4">
              <span className="text-xs font-bold uppercase tracking-widest text-atlas-soft">Legal</span>
              <a href="/privacy" className="text-sm font-bold text-atlas-muted hover:text-atlas-ink transition-colors">Privacy</a>
              <a href="/terms" className="text-sm font-bold text-atlas-muted hover:text-atlas-ink transition-colors">Terms</a>
            </div>
          </div>
        </div>

        <div className="mt-20 pt-8 border-t border-atlas-line flex flex-col md:flex-row justify-between items-center gap-4 text-xs font-bold text-atlas-soft">
          <p>© {new Date().getFullYear()} Atlas Fitness OS.</p>
          <p>Version {SITE.apkVersion}</p>
        </div>
      </div>
    </footer>
  );
}