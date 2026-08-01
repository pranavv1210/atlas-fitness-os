import { clsx } from 'clsx';

type GlassButtonProps = {
  href: string;
  children: React.ReactNode;
  icon?: React.ReactNode;
  variant?: 'primary' | 'quiet';
  download?: boolean;
};

export function GlassButton({ href, children, icon, variant = 'primary', download }: GlassButtonProps) {
  return (
    <a
      href={href}
      download={download}
      className={clsx('glass-button group', variant === 'quiet' && 'glass-button-quiet')}
    >
      <span>{children}</span>
      {icon && <span className="transition-transform duration-300 group-hover:translate-x-1">{icon}</span>}
    </a>
  );
}
