
import React from 'react';

type BadgeVariant = 'default' | 'primary' | 'success' | 'warning' | 'outline';

interface BadgeProps {
  children: React.ReactNode;
  variant?: BadgeVariant;
  className?: string;
}

const VARIANTS: Record<BadgeVariant, string> = {
  default: 'bg-zinc-900 text-zinc-400 border border-zinc-800',
  primary: 'bg-amber-500/10 text-amber-500 border border-amber-500/20 shadow-[0_0_10px_rgba(245,158,11,0.1)]',
  success: 'bg-emerald-500/10 text-emerald-500 border border-emerald-500/20',
  warning: 'bg-orange-500/10 text-orange-500 border border-orange-500/20',
  outline: 'bg-transparent text-zinc-500 border border-zinc-700',
};

export const Badge: React.FC<BadgeProps> = ({ children, variant = 'default', className = '' }) => {
  return (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded text-[9px] uppercase tracking-widest font-bold font-sans ${VARIANTS[variant]} ${className}`}>
      {children}
    </span>
  );
};
