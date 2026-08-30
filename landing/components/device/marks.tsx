/**
 * Bespoke marks. Everything else uses lucide-react; these three are
 * drawn by hand because they are specific to Atlas.
 */

/**
 * The assistant's face - a 25 LB weight plate. This is the app's own
 * glyph, not an invented mascot, and it is the one warm gesture in an
 * otherwise instrument-like interface.
 */
export function PlateFace({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 64 64" className={className} aria-hidden="true">
      <defs>
        <linearGradient id="atlas-plate" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#2f3238" />
          <stop offset="1" stopColor="#121212" />
        </linearGradient>
      </defs>
      <circle cx="32" cy="32" r="29" fill="url(#atlas-plate)" />
      <circle cx="32" cy="32" r="23" fill="none" stroke="rgba(255,255,255,.16)" strokeWidth="1.4" />
      <circle cx="32" cy="30" r="12" fill="#FAF8F4" />
      <circle cx="28.4" cy="29" r="1.7" fill="#121212" />
      <circle cx="35.6" cy="29" r="1.7" fill="#121212" />
      <path
        d="M28.2 33.4c1 1.5 2.3 2.2 3.8 2.2s2.8-.7 3.8-2.2"
        fill="none"
        stroke="#121212"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <text
        x="32"
        y="51.4"
        textAnchor="middle"
        fill="rgba(255,255,255,.82)"
        fontSize="7.6"
        fontWeight="700"
        letterSpacing="1.1"
        fontFamily="ui-monospace, SFMono-Regular, Menlo, monospace"
      >
        25 LB
      </text>
    </svg>
  );
}

/**
 * The cycle mark: five segments, four of them work and one rest,
 * arranged as a ring because the cycle has no end - it only advances.
 */
export function CycleMark({ active = 0, className }: { active?: number; className?: string }) {
  const gap = 7;
  const seg = 360 / 5;
  return (
    <svg viewBox="0 0 48 48" className={className} aria-hidden="true">
      {[0, 1, 2, 3, 4].map((i) => {
        const start = i * seg + gap / 2 - 90;
        const end = (i + 1) * seg - gap / 2 - 90;
        const r = 20;
        const x1 = 24 + r * Math.cos((start * Math.PI) / 180);
        const y1 = 24 + r * Math.sin((start * Math.PI) / 180);
        const x2 = 24 + r * Math.cos((end * Math.PI) / 180);
        const y2 = 24 + r * Math.sin((end * Math.PI) / 180);
        const isRest = i === 4;
        return (
          <path
            key={i}
            d={`M ${x1} ${y1} A ${r} ${r} 0 0 1 ${x2} ${y2}`}
            fill="none"
            stroke="currentColor"
            strokeWidth={i === active ? 5 : 3}
            strokeLinecap="round"
            opacity={i === active ? 1 : isRest ? 0.22 : 0.38}
            strokeDasharray={isRest ? '2 4' : undefined}
          />
        );
      })}
    </svg>
  );
}

/** The Atlas monogram: a bar loaded on both sides. */
export function AtlasMark({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 32 32" className={className} aria-hidden="true">
      <rect x="2" y="14" width="28" height="4" rx="2" fill="currentColor" opacity=".92" />
      <rect x="5" y="9" width="4.5" height="14" rx="2.25" fill="currentColor" />
      <rect x="22.5" y="9" width="4.5" height="14" rx="2.25" fill="currentColor" />
      <rect x="12" y="11.5" width="3" height="9" rx="1.5" fill="currentColor" opacity=".5" />
      <rect x="17" y="11.5" width="3" height="9" rx="1.5" fill="currentColor" opacity=".5" />
    </svg>
  );
}
