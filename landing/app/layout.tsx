import type { Metadata, Viewport } from 'next';
import { Geist } from 'next/font/google';
import './globals.css';

const geist = Geist({
  subsets: ['latin'],
  variable: '--font-geist-sans',
  display: 'swap',
});

export const metadata: Metadata = {
  metadataBase: new URL('https://atlas-fitness-os.vercel.app'),
  title: 'Atlas | Personal Fitness Operating System',
  description:
    'Atlas is a premium Android fitness operating system for workouts, goals, hydration, analytics, and an AI gym buddy.',
  keywords: [
    'Atlas fitness app',
    'workout tracker',
    'gym tracker',
    'fitness operating system',
    'AI fitness coach',
    'exercise library',
    'hydration tracking',
  ],
  openGraph: {
    title: 'Atlas | Personal Fitness Operating System',
    description:
      'A premium Android fitness app for workout logging, 2,000+ exercises, goals, hydration, progress, and Atlas Buddy.',
    type: 'website',
    url: 'https://atlas-fitness-os.vercel.app',
    images: ['/brand/atlas-logo.png'],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Atlas | Personal Fitness Operating System',
    description:
      'A premium Android fitness app for workout logging, 2,000+ exercises, goals, hydration, progress, and Atlas Buddy.',
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
