import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        atlas: {
          paper: '#FAF8F4',
          paper2: '#F2EEE6',
          ink: '#090A0C',
          graphite: '#0E1116',
          graphite2: '#161B23',
          graphite3: '#1D2430',
          muted: '#666D77',
          soft: '#9CA3AF',
          blue: '#1A56DB',
          deep: '#1135A5',
          cyan: '#15B8D6',
          success: '#059669',
        },
      },
      fontFamily: {
        sans: ['Gilroy', 'Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        soft: '0 24px 70px rgba(17, 19, 22, 0.08)',
        glass: '0 28px 90px rgba(17, 19, 22, 0.12)',
        glow: '0 24px 80px rgba(26, 86, 219, 0.25)',
        'dark-soft': '0 32px 90px rgba(0, 0, 0, 0.5)',
        'glass-panel': 'inset 0 1px 1px rgba(255, 255, 255, 0.1), 0 8px 32px rgba(0, 0, 0, 0.08)',
      },
      letterSpacing: {
        tighter: '0',
        tight: '0',
        widest: '0.15em',
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'glass-gradient': 'linear-gradient(145deg, rgba(255, 255, 255, 0.8), rgba(255, 255, 255, 0.4))',
        'glass-dark': 'linear-gradient(145deg, rgba(22, 27, 35, 0.6), rgba(14, 17, 22, 0.9))',
      },
    },
  },
  plugins: [],
};

export default config;
