import { Download, Home } from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';
import { SITE } from '@/lib/site';

export default function NotFound() {
  return (
    <main className="min-h-[100svh] flex flex-col items-center justify-center p-6 bg-atlas-paper relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-radial from-atlas-blue/5 to-transparent pointer-events-none" />
      <div className="relative z-10 mx-auto max-w-2xl text-center">
        <div className="text-[200px] font-black text-atlas-ink/5 tracking-tighter leading-none select-none" aria-hidden="true">
          404
        </div>
        <Image
          src="/brand/atlas-logo.png"
          alt=""
          width={56}
          height={56}
          priority
          className="mx-auto -mt-24 rounded-2xl shadow-glow relative z-20"
        />
        <h1 className="mt-8 text-[clamp(36px,6.4vw,64px)] font-black leading-[0.94] tracking-normal text-atlas-ink">
          Looks like this route missed the workout.
        </h1>
        <p className="mx-auto mt-6 max-w-md text-lg leading-relaxed text-atlas-muted">
          The page you are looking for is not part of the Atlas system. The system itself is still
          here - and the next workout is one tap away.
        </p>
        <div className="mt-10 flex flex-col sm:flex-row justify-center gap-4">
          <Link href="/" className="btn btn-primary">
            <Home size={18} className="mr-2" />
            Back to Atlas
          </Link>
          <a href={SITE.apkUrl} download className="btn btn-secondary">
            <Download size={18} className="mr-2" />
            Download APK
          </a>
        </div>
      </div>
    </main>
  );
}