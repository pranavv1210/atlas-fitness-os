import { Nav } from '../components/nav';
import { HeroReimagined } from '../components/hero-reimagined';
import { ProblemTransformation } from '../components/problem-transformation';
import { OsArchitecture } from '../components/os-architecture';
import { ScrollStory } from '../components/scroll-story';
import { LibraryShowcase } from '../components/library-showcase';
import { HydrationLiquid } from '../components/hydration-liquid';
import { ConsistencyTimeline } from '../components/consistency-timeline';
import { Constellation } from '../components/constellation';
import { Faq } from '../components/faq';
import { FinalCta } from '../components/final-cta';
import { Footer } from '../components/footer';
import { SITE } from '@/lib/site';

const faqData = [
  {
    question: 'What is Atlas?',
    answer:
      'Atlas is a personal fitness operating system for Android. It brings workout planning, logging, exercise discovery, history, hydration, goals, and progress analytics into one account-protected system.',
  },
  {
    question: 'Who is Atlas for?',
    answer:
      'Anyone who trains with structure. Beginners get a fixed five-day cycle and a curated exercise library. Experienced lifters get set-by-set history, weekly volume, body-weight trends, recovery context, and goal tracking.',
  },
  {
    question: 'How many exercises are included?',
    answer:
      `${SITE.exerciseCount} unique exercises are bundled with the app. ${SITE.exerciseWithInstructions} include step-by-step instructions and ${SITE.exerciseWithImages} include imagery, with search across name, muscle, equipment, difficulty, and movement pattern.`,
  },
];

export default function Home() {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@graph': [
      {
        '@type': 'SoftwareApplication',
        name: 'Atlas Fitness OS',
        alternateName: 'Atlas',
        applicationCategory: 'HealthApplication',
        operatingSystem: 'Android',
        description:
          'Atlas is a personal fitness operating system for workout planning, logging, exercise discovery, history, hydration, goals, and progress tracking.',
        downloadUrl: `${SITE.baseUrl}/downloads/atlas-release.apk`,
        codeRepository: SITE.repoUrl,
        offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
      },
      {
        '@type': 'WebSite',
        name: 'Atlas',
        url: SITE.baseUrl,
        description: SITE.tagline,
      },
      {
        '@type': 'Organization',
        name: 'Atlas',
        url: SITE.baseUrl,
        logo: `${SITE.baseUrl}/brand/atlas-logo.png`,
      },
      {
        '@type': 'FAQPage',
        mainEntity: faqData.map((item) => ({
          '@type': 'Question',
          name: item.question,
          acceptedAnswer: { '@type': 'Answer', text: item.answer },
        })),
      },
    ],
  };

  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <a href="#main" className="skip-link">
        Skip to content
      </a>
      <Nav />
      <main id="main">
        <HeroReimagined />
        <ProblemTransformation />
        <OsArchitecture />
        <ScrollStory />
        <LibraryShowcase />
        <HydrationLiquid />
        <ConsistencyTimeline />
        {/* We keep the old Constellation, Faq, and Final CTA but they will inherit the new CSS automatically */}
        <Constellation />
        <Faq />
        <FinalCta />
      </main>
      <Footer />
    </>
  );
}
