import type { Metadata, Viewport } from 'next';
import './globals.css';
import { SITE } from '@/lib/site';

const description =
  `Atlas is a personal fitness operating system for Android. Plan workouts, log every set, discover ${SITE.exerciseCount} exercises, and track your history, hydration, and goals within a single, interconnected system.`;

export const metadata: Metadata = {
  metadataBase: new URL(SITE.baseUrl),
  title: {
    default: 'Atlas - Your Personal Fitness Operating System',
    template: '%s - Atlas',
  },
  description,
  keywords: [
    'Atlas fitness app',
    'fitness operating system',
    'workout tracker',
    'exercise library',
    'workout logging',
    'exercise library',
    'workout history',
    'fitness progress tracking',
    'hydration tracking',
    'fitness goals',
    'body weight tracking',
    'Android fitness app',
  ],
  alternates: {
    canonical: '/',
  },
  openGraph: {
    title: 'Atlas - Your Personal Fitness Operating System',
    description,
    type: 'website',
    url: SITE.baseUrl,
    siteName: 'Atlas',
    locale: 'en_US',
    images: [
      {
        url: '/og/atlas-og.png',
        width: 1200,
        height: 630,
        alt: 'Atlas - Your Personal Fitness Operating System',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Atlas - Your Personal Fitness Operating System',
    description,
    images: ['/og/atlas-og.png'],
  },
  icons: {
    icon: [
      { url: '/brand/favicon-32.png', sizes: '32x32', type: 'image/png' },
      { url: '/brand/favicon-16.png', sizes: '16x16', type: 'image/png' },
    ],
    shortcut: '/brand/favicon-32.png',
    apple: [{ url: '/brand/apple-touch-icon.png', sizes: '180x180', type: 'image/png' }],
  },
  manifest: '/manifest.webmanifest',
  robots: {
    index: true,
    follow: true,
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  themeColor: '#FAF8F4',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
