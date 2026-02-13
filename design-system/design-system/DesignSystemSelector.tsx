import React, { useState, useRef, useEffect } from 'react';
import { Command, ChevronDown, Check, Plus } from 'lucide-react';
import { DESIGN_SYSTEMS } from '../../constants';

interface DesignSystemSelectorProps {
  currentId: string;
  onSelect: (id: string) => void;
}

export const DesignSystemSelector: React.FC<DesignSystemSelectorProps> = ({ currentId, onSelect }) => {
  const [isOpen, setIsOpen] = useState(false);
  const activeDS = DESIGN_SYSTEMS.find(ds => ds.id === currentId) || DESIGN_SYSTEMS[0];
  const selectorRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (selectorRef.current && !selectorRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <div className="relative z-50" ref={selectorRef}>
       <button
         onClick={() => setIsOpen(!isOpen)}
         className="flex items-center gap-3 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 hover:border-zinc-300 dark:hover:border-zinc-700 rounded-xl px-4 py-3 transition-all w-64 justify-between group shadow-sm"
       >
         <div className="flex items-center gap-3">
             <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-zinc-100 to-zinc-200 dark:from-zinc-800 dark:to-zinc-900 border border-zinc-200 dark:border-zinc-700 flex items-center justify-center text-eximia-600 dark:text-eximia-400 shadow-inner group-hover:scale-105 transition-transform">
                 <Command className="w-4 h-4" />
             </div>
             <div className="text-left">
                 <p className="text-xs text-zinc-500 font-medium uppercase tracking-wider">System</p>
                 <p className="text-sm font-bold text-zinc-800 dark:text-zinc-200">{activeDS.name}</p>
             </div>
         </div>
         <ChevronDown className={`w-4 h-4 text-zinc-500 transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`} />
       </button>

       {isOpen && (
         <div className="absolute top-full left-0 mt-2 w-72 bg-white dark:bg-[#18181B] border border-zinc-200 dark:border-zinc-800 rounded-xl shadow-2xl z-50 overflow-hidden animate-in fade-in zoom-in-95 duration-200 ring-1 ring-black/10">
              <div className="p-2">
                  <div className="px-3 py-2 text-xs font-bold text-zinc-500 uppercase tracking-wider">Select System</div>
                  {DESIGN_SYSTEMS.map(ds => (
                      <button
                        key={ds.id}
                        onClick={() => {
                            onSelect(ds.id);
                            setIsOpen(false);
                        }}
                        className={`
                            w-full text-left flex items-start gap-3 px-3 py-3 rounded-lg transition-colors mb-1
                            ${ds.id === currentId ? 'bg-zinc-100 dark:bg-zinc-800/80 border border-zinc-200 dark:border-zinc-700/50' : 'hover:bg-zinc-50 dark:hover:bg-zinc-800/50 border border-transparent'}
                        `}
                      >
                         <div className={`w-2 h-2 rounded-full mt-1.5 ${ds.id === currentId ? 'bg-eximia-500 dark:bg-eximia-400 shadow-[0_0_8px_rgba(253,191,104,0.5)]' : 'bg-zinc-300 dark:bg-zinc-700'}`} />
                         <div>
                             <p className={`text-sm font-bold ${ds.id === currentId ? 'text-zinc-900 dark:text-zinc-100' : 'text-zinc-500 dark:text-zinc-400'}`}>{ds.name}</p>
                             <p className="text-xs text-zinc-500 line-clamp-1">{ds.description.substring(0, 40)}...</p>
                         </div>
                         {ds.id === currentId && <Check className="w-4 h-4 text-eximia-500 dark:text-eximia-400 ml-auto mt-0.5" />}
                      </button>
                  ))}
                  <div className="border-t border-zinc-200 dark:border-zinc-800 mt-2 pt-2 px-3 pb-2">
                      <button className="text-xs text-zinc-500 hover:text-zinc-700 dark:hover:text-zinc-300 flex items-center gap-2 w-full transition-colors">
                          <Plus className="w-3 h-3" /> Create New System
                      </button>
                  </div>
              </div>
          </div>
       )}
    </div>
  );
};