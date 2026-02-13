import React from 'react';

type LogoSize = 'sm' | 'md' | 'lg' | 'xl';
type LogoVariant = 'full' | 'icon';

interface LogoProps {
  size?: LogoSize;
  variant?: LogoVariant;
  className?: string;
  onClick?: () => void;
}

const SIZES = {
  sm: {
    icon: 'w-4 h-4',
    text: 'text-sm',
    os: 'text-[10px]'
  },
  md: {
    icon: 'w-6 h-6',
    text: 'text-xl',
    os: 'text-[14px]'
  },
  lg: {
    icon: 'w-8 h-8',
    text: 'text-3xl',
    os: 'text-[21px]'
  },
  xl: {
    icon: 'w-10 h-10',
    text: 'text-4xl',
    os: 'text-[28px]'
  }
};

/**
 * Logo Component - exímIA OS
 *
 * Horizontal layout: Icon + "eximIA" + "OS"
 * - Icon: Amber and white symbol
 * - Text: White "eximIA" + Amber "OS" (70% size)
 *
 * @param size - sm | md | lg | xl (default: md)
 * @param variant - full (icon + text) | icon (only symbol) (default: full)
 */
export const Logo: React.FC<LogoProps> = ({
  size = 'md',
  variant = 'full',
  className = '',
  onClick
}) => {
  const sizeClasses = SIZES[size];

  // Icon SVG (used in both variants)
  const IconSVG = () => (
    <div className={`${sizeClasses.icon} flex-shrink-0`}>
      <svg viewBox="0 0 120 136" className="w-full h-full" fill="none" xmlns="http://www.w3.org/2000/svg">
        {/* Symbol Right (Amber) */}
        <path d="M58.88,132.06c0,2.84,2.96,4.72,5.53,3.5l51-24.09c3.04-1.44,4.99-4.51,4.98-7.89l-.02-23.87v-1.81s-.06-60.95-.06-60.95c0-3.57-2.31-6.73-5.72-7.81L87.3.46c-5.29-1.68-10.7,2.27-10.69,7.83l.04,38.51c.01,11.07,7.12,20.88,17.63,24.32l23.61,7.78-53.28,21.38c-3.48,1.39-5.75,4.77-5.75,8.51l.02,23.27Z" fill="#f59e0b"/>
        {/* Symbol Left (White) */}
        <path d="M61.33,3.85c-.02-2.84-2.99-4.7-5.56-3.47L4.93,24.8C1.9,26.27-.02,29.35,0,32.73l.18,23.87v1.81s.47,60.94.47,60.94c.03,3.57,2.36,6.71,5.77,7.77l27.35,8.51c5.3,1.65,10.68-2.34,10.64-7.89l-.29-38.51c-.08-11.07-7.26-20.83-17.79-24.21l-23.66-7.62,53.14-21.73c3.47-1.42,5.72-4.8,5.69-8.55l-.17-23.27Z" fill="#FFFFFF"/>
      </svg>
    </div>
  );

  // Icon only variant
  if (variant === 'icon') {
    return (
      <div
        className={`inline-flex items-center ${onClick ? 'cursor-pointer' : ''} ${className}`}
        onClick={onClick}
      >
        <IconSVG />
      </div>
    );
  }

  // Full variant (icon + text)
  return (
    <div
      className={`inline-flex items-baseline gap-2 ${onClick ? 'cursor-pointer' : ''} ${className}`}
      onClick={onClick}
    >
      <IconSVG />

      {/* Brand Text */}
      <div className="flex items-baseline gap-1">
        <span className={`${sizeClasses.text} font-bold text-white tracking-tight`}>
          eximIA
        </span>
        {/* OS - 70% do tamanho de eximIA */}
        <span className={`${sizeClasses.os} font-bold text-amber-500 tracking-wider`}>
          OS
        </span>
      </div>
    </div>
  );
};
