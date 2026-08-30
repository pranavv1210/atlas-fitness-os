import type { MetadataRoute } from 'next';

export const dynamic = 'force-static';

const baseUrl = 'https://atlas-fitness-os-henna.vercel.app';

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    {
      url: baseUrl,
      lastModified: new Date('2026-08-30'),
      changeFrequency: 'weekly',
      priority: 1,
    },
  ];
}
