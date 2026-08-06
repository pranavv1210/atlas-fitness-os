import type { Metadata, Viewport } from 'next';
import { Geist } from 'next/font/google';
import './globals.css';

const geist = Geist({
  subsets: ['latin'],
  variable: '--font-geist-sans',
  display: 'swap',
});

export const metadata: Metadata = {
  metadataBase: new URL('https://atlas-fitness-os-henna.vercel.app'),
  title: 'Atlas | Personal Fitness Operating System',
  description:
    'Atlas is a premium Android fitness operating system for secure Google login, workout logging, 2,069+ exercises, daily reports, hydration, goals, progress analytics, and Atlas Buddy.',
  keywords: [
    'Atlas fitness app',
    'workout tracker',
    'gym tracker',
    'fitness operating system',
    'AI fitness coach',
    'exercise library',
    'hydration tracking',
    'fitness analytics',
    'Google sign in fitness app',
    'workout history',
    'daily workout report',
  ],
  openGraph: {
    title: 'Atlas | Personal Fitness Operating System',
    description:
      'A premium Android fitness app for secure accounts, workout logging, 2,069+ exercises, goals, hydration, progress, daily reports, and Atlas Buddy.',
    type: 'website',
    url: 'https://atlas-fitness-os-henna.vercel.app',
    images: ['/brand/atlas-logo.png'],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Atlas | Personal Fitness Operating System',
    description:
      'A premium Android fitness app for secure accounts, workout logging, 2,069+ exercises, goals, hydration, progress, daily reports, and Atlas Buddy.',
    images: ['/brand/atlas-logo.png'],
  },
  icons: {
    icon: '/brand/atlas-logo.png',
    shortcut: '/brand/atlas-logo.png',
    apple: '/brand/atlas-logo.png',
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  themeColor: '#FAF8F4',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={geist.variable}>
      <body>{children}</body>
    </html>
  );
}
