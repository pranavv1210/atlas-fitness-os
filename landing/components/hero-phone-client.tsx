'use client';

import dynamic from 'next/dynamic';

const HeroPhone = dynamic(() => import('./hero-phone').then((mod) => mod.HeroPhone), {
  ssr: false,
  loading: () => <div className="hero-phone-fallback" aria-hidden="true" />,
});

export function HeroPhoneClient() {
  return <HeroPhone />;
}
