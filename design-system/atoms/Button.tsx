
import React from 'react';

type ButtonVariant = 'primary' | 'secondary' | 'outline' | 'ghost' | 'destructive';
type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  icon?: React.ReactNode;
}

const VARIANTS: Record<ButtonVariant, string> = {
  primary: 'bg-white text-black hover:bg-zinc-200 border border-transparent shadow-[0_0_15px_rgba(255,255,255,0.15)] font-bold tracking-wide',
  secondary: 'bg-[#121214] text-zinc-200 hover:bg-[#1A1A1E] border border-zinc-800 hover:border-zinc-700 font-medium',
  outline: 'bg-transparent border border-zinc-700 text-zinc-400 hover:text-white hover:border-zinc-500 font-medium',
  ghost: 'bg-transparent text-zinc-500 hover:text-white hover:bg-white/5 font-medium',
  destructive: 'bg-rose-950/30 text-rose-500 border border-rose-900/50 hover:bg-rose-950/50 hover:border-rose-800 font-medium',
};

const SIZES: Record<ButtonSize, string> = {
  sm: 'h-8 px-3 text-[10px] uppercase tracking-wider',
  md: 'h-10 px-4 text-xs uppercase tracking-wider',
  lg: 'h-12 px-6 text-sm uppercase tracking-wider',
};

export const Button: React.FC<ButtonProps> = ({ 
  children, 
  variant = 'primary', 
  size = 'md', 
  icon,
  className = '',
  ...props 
}) => {
  return (
    <button 
      className={`
        inline-flex items-center justify-center rounded-lg transition-all duration-200
        focus:outline-none focus:ring-2 focus:ring-zinc-500 focus:ring-offset-2 focus:ring-offset-black
        disabled:opacity-50 disabled:cursor-not-allowed
        ${VARIANTS[variant]} 
        ${SIZES[size]} 
        ${className}
      `}
      {...props}
    >
      {icon && <span className="mr-2">{icon}</span>}
      {children}
    </button>
  );
};
