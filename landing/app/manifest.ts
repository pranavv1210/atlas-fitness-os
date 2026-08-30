import type { MetadataRoute } from 'next';

export const dynamic = 'force-static';

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: 'Atlas Fitness OS',
    short_name: 'Atlas',
    description: 'Personal fitness operating system for Android.',
    start_url: '/',
    display: 'standalone',
    background_color: '#111214',
    theme_color: '#111214',
    icons: [
      {
        src: '/brand/atlas-logo.png',
        sizes: '512x512',
        type: 'image/png',
      },
    ],
  };
}
