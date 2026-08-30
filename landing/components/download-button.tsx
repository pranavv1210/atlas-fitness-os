'use client';

import { Check, Download, Loader2 } from 'lucide-react';
import { useRef, useState } from 'react';
import { SITE } from '@/lib/site';

type DownloadState = 'idle' | 'downloading' | 'done';

/**
 * Real APK download control with a small state machine.
 * Remains an anchor so the browser performs a native download.
 */
export function DownloadButton({ className = '', label = 'Download Atlas' }: { className?: string; label?: string }) {
  const [state, setState] = useState<DownloadState>('idle');
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const reduced = useRef(false);

  const icon =
    state === 'downloading' ? (
      <Loader2 className="animate-spin" size={18} aria-hidden="true" />
    ) : state === 'done' ? (
      <Check size={18} aria-hidden="true" />
    ) : (
      <Download size={18} aria-hidden="true" />
    );

  const text = state === 'idle' ? label : state === 'downloading' ? 'Downloading…' : 'Download started';

  return (
    <a
      href={SITE.apkUrl}
      download
      data-state={state}
      aria-busy={state === 'downloading'}
      onClick={(event) => {
        if (state === 'done' || state === 'downloading') {
          event.preventDefault();
          return;
        }
        setState('downloading');
        if (timer.current) clearTimeout(timer.current);
        timer.current = setTimeout(() => {
          setState('done');
          reduced.current = true;
          setTimeout(() => {
            if (reduced.current) setState('idle');
          }, 3200);
        }, 900);
      }}
      className={`btn btn-primary btn-download ${className}`}
    >
      {icon}
      <span>{text}</span>
    </a>
  );
}