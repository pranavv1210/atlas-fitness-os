import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        atlas: {
          background: '#FAF8F4',
          cream: '#F7F5F1',
          pearl: '#F3F2EE',
          surface: '#FFFFFF',
          ink: '#121212',
          muted: '#666666',
          soft: '#9A968D',
          accent: '#2563FF',
          deep: '#173BBD',
          success: '#10B981',
          warning: '#F59E0B',
          lilac: '#8B7AE6',
        },
      },
      borderRadius: {
        atlas: '30px',
        'atlas-lg': '44px',
      },
      boxShadow: {
        glass: '0 28px 90px rgba(18, 18, 18, 0.12)',
        glow: '0 24px 80px rgba(37, 99, 255, 0.24)',
      },
      fontFamily: {
        sans: ['var(--font-geist-sans)', 'Inter', 'ui-sans-serif', 'system-ui'],
      },
    },
  },
  plugins: [],
};

export default config;
