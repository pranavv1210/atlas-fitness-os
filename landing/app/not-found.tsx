import Image from 'next/image';
import { Download, Home } from 'lucide-react';
import { GlassButton } from '../components/glass-button';

export default function NotFound() {
  return (
    <main className="not-found-page">
      <section className="not-found-panel">
        <Image src="/brand/atlas-logo.png" alt="" width={58} height={58} priority />
        <span className="section-kicker">404</span>
        <h1>This route is not in the Atlas system.</h1>
        <p>Return to the product story or download the current Android APK.</p>
        <div className="cta-row">
          <GlassButton href="/" variant="quiet" icon={<Home size={18} />}>Home</GlassButton>
          <GlassButton href="/downloads/atlas-release.apk" download icon={<Download size={18} />}>Download APK</GlassButton>
        </div>
      </section>
    </main>
  );
}
