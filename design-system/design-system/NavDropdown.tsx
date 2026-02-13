
import React, { useRef, useEffect } from 'react';
import { ChevronDown } from 'lucide-react';

interface NavDropdownProps {
  label: string;
  isActive: boolean;
  isOpen: boolean;
  onToggle: () => void;
  onSelect: (value: string) => void;
  options: { id: string; label: string; icon?: React.ElementType }[];
}

export const NavDropdown: React.FC<NavDropdownProps> = ({ 
  label, 
  isActive, 
  isOpen, 
  onToggle, 
  onSelect, 
  options 
}) => {
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        if (isOpen) onToggle();
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [isOpen, onToggle]);

  return (
    <div className="relative z-20" ref={dropdownRef}>
      <button 
        onClick={onToggle}
        className={`
          flex items-center gap-1.5 text-xs font-bold tracking-widest transition-colors uppercase
          ${isActive 
            ? 'text-white' 
            : 'text-zinc-500 hover:text-zinc-300'}
        `}
      >
        {label}
        <ChevronDown className={`w-3 h-3 transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`} />
      </button>

      {isOpen && options.length > 0 && (
        <div className="absolute top-full left-1/2 -translate-x-1/2 mt-4 w-52 bg-[#18181B] border border-zinc-800 rounded-xl shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-100 z-50">
          <div className="p-1.5">
            {options.map((opt) => (
              <button
                key={opt.id}
                onClick={() => {
                  onSelect(opt.id);
                  onToggle();
                }}
                className="w-full text-left flex items-center gap-3 px-3 py-2.5 text-xs font-medium text-zinc-400 hover:text-white hover:bg-zinc-800 rounded-lg transition-colors"
              >
                {opt.icon && <opt.icon className="w-3.5 h-3.5 opacity-70" />}
                {opt.label}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
