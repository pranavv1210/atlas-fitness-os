import type { Metadata } from 'next';
import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import { SITE } from '@/lib/site';

export const metadata: Metadata = {
  title: 'Terms of Service',
  description: 'The terms that apply when you download and use the Atlas fitness application.',
  alternates: { canonical: '/terms' },
};

export default function TermsPage() {
  return (
    <div className="legal-page">
      <div className="legal-card">
        <Link
          href="/"
          className="mb-12 inline-flex items-center gap-2 text-[14px] font-extrabold tracking-normal text-[var(--muted)] transition-colors hover:text-[var(--ink)]"
        >
          <ArrowLeft size={16} />
          Back to Atlas
        </Link>
        <h1 className="mt-8">Terms</h1>
        <p className="!text-[16px]">
          These terms apply when you download and use the Atlas Android application. By installing
          or using Atlas, you agree to them.
        </p>

        <h2>What Atlas is</h2>
        <p>
          Atlas is a personal fitness tracking application. It helps you plan training, log
          workouts, track hydration and body weight, set goals, and review your history and
          progress.
        </p>

        <h2>The information you log is yours</h2>
        <p>
          Workout logs and other records you create in Atlas belong to your account. You can delete
          them at any time through the application.
        </p>

        <h2>Not medical advice</h2>
        <p>
          Atlas is not a medical device and does not provide medical advice, diagnosis, or
          treatment. Consult a qualified professional before starting or changing a training,
          nutrition, or health program. You are responsible for exercises you choose to perform.
        </p>

        <h2>Availability</h2>
        <p>
          Atlas is provided as-is, without warranties of any kind. The application, its features,
          and these terms may change as the product evolves. Atlas remains an Android application;
          iOS is not currently supported.
        </p>

        <h2>Open source</h2>
        <p>
          The Atlas source code is available on GitHub at{' '}
          <a href={SITE.repoUrl} target="_blank" rel="noreferrer" className="font-extrabold text-[var(--blue)]">
            {SITE.repoUrl}
          </a>
          .
        </p>
      </div>
    </div>
  );
}
