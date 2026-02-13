import React from 'react';

type InputSize = 'sm' | 'md' | 'lg';

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  size?: InputSize;
  icon?: React.ReactNode;
}

const SIZES: Record<InputSize, string> = {
  sm: 'h-8 px-3 text-xs',
  md: 'h-10 px-4 text-sm',
  lg: 'h-12 px-5 text-base',
};

export const Input: React.FC<InputProps> = ({
  label,
  error,
  size = 'md',
  icon,
  className = '',
  ...props
}) => {
  return (
    <div className="flex flex-col gap-1.5">
      {label && (
        <label className="text-xs font-medium text-zinc-400 uppercase tracking-wider">
          {label}
        </label>
      )}
      <div className="relative">
        {icon && (
          <div className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-500">
            {icon}
          </div>
        )}
        <input
          className={`
            w-full rounded-lg transition-all duration-200
            bg-[#121214] border
            ${error
              ? 'border-rose-900/50 focus:border-rose-800 focus:ring-rose-950/30'
              : 'border-zinc-800 focus:border-zinc-600 focus:ring-zinc-900/50'
            }
            text-zinc-200 placeholder:text-zinc-600
            focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-black
            disabled:opacity-50 disabled:cursor-not-allowed
            ${SIZES[size]}
            ${icon ? 'pl-10' : ''}
            ${className}
          `}
          {...props}
        />
      </div>
      {error && (
        <span className="text-xs text-rose-500 font-medium">
          {error}
        </span>
      )}
    </div>
  );
};
