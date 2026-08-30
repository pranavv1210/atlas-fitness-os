import type { Metadata } from 'next';
import Image from 'next/image';
import Link from 'next/link';
import { SITE } from '@/lib/site';

export const metadata: Metadata = {
  title: 'Privacy',
  description: 'How Atlas handles your data - authentication, storage, and device protection.',
  alternates: { canonical: '/privacy' },
};

export default function PrivacyPage() {
  return (
    <div className="legal-page">
      <div className="legal-card">
        <Link href="/" className="brand-mark text-[15px]">
          <Image src="/brand/atlas-logo.png" alt="Atlas logo" width={30} height={30} />
          <span>Atlas</span>
        </Link>
        <h1 className="mt-8">Privacy</h1>
        <p className="!text-[16px]">
          This page describes how the Atlas Android application handles personal data. It is written
          for the product as it exists today and will be updated as the product evolves.
        </p>

        <h2>Data you provide</h2>
        <p>
          Atlas stores the data you enter while training and using the app: workout logs (exercises,
          sets, reps, weight, notes), body-weight entries, hydration logs, goals, and
          profile fields used to calculate metrics such as BMI.
        </p>

        <h2>Authentication</h2>
        <p>
          Atlas uses Google sign-in through Supabase authentication to identify your account.
          Sessions are scoped to that identity, and database rows are protected by Supabase
          row-level security so each account can only read and write its own data.
        </p>

        <h2>Storage and sync</h2>
        <p>
          Atlas is designed online-first: your data is stored in Supabase and synced to the app,
          with a local cache for smoother reads when connectivity is limited. Exercise reference
          imagery is loaded from the network.
        </p>

        <h2>Device protection</h2>
        <p>
          Atlas offers an optional biometric lock that protects the app locally on your device.
          Biometric verification is handled by the operating system and is not uploaded anywhere.
        </p>

        <h2>What Atlas does not do</h2>
        <ul>
          <li>Atlas does not display advertising.</li>
          <li>Atlas does not include public social features or profile sharing.</li>
          <li>Atlas does not provide medical advice or diagnosis.</li>
        </ul>

        <h2>Contact</h2>
        <p>
          For privacy questions, open an issue on the Atlas repository at{' '}
          <a href={SITE.repoUrl} target="_blank" rel="noreferrer" className="font-extrabold text-[var(--blue)]">
            {SITE.repoUrl}
          </a>
          .
        </p>
      </div>
    </div>
  );
}
