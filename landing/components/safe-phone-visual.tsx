'use client';

import { Component, type ErrorInfo, type ReactNode, useEffect, useState } from 'react';
import { HeroPhoneClient } from './hero-phone-client';

class PhoneErrorBoundary extends Component<{ children: ReactNode }, { failed: boolean }> {
  state = { failed: false };

  static getDerivedStateFromError() {
    return { failed: true };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.warn('Atlas phone visual fallback activated', error, info.componentStack);
  }

  render() {
    if (this.state.failed) {
      return <CssPhoneVisual />;
    }
    return this.props.children;
  }
}

export function SafePhoneVisual() {
  const [canRenderWebgl, setCanRenderWebgl] = useState(false);

  useEffect(() => {
    if (navigator.webdriver) {
      setCanRenderWebgl(false);
      return;
    }
    const isDesktopPointer = window.matchMedia('(min-width: 1025px) and (hover: hover) and (pointer: fine)').matches;
    if (!isDesktopPointer) {
      setCanRenderWebgl(false);
      return;
    }
    const canvas = document.createElement('canvas');
    const gl = canvas.getContext('webgl2') ?? canvas.getContext('webgl') ?? canvas.getContext('experimental-webgl');
    setCanRenderWebgl(Boolean(gl));
  }, []);

  if (!canRenderWebgl) {
    return <CssPhoneVisual />;
  }

  return (
    <PhoneErrorBoundary>
      <HeroPhoneClient />
    </PhoneErrorBoundary>
  );
}

function CssPhoneVisual() {
  return (
    <div className="css-phone-visual" aria-hidden="true">
      <span />
      <i />
      <b />
    </div>
  );
}
