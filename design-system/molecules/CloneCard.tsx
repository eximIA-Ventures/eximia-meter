import React from 'react';
import { Clone } from '../../types';
import { MoreHorizontal, Play, Activity } from 'lucide-react';

interface CloneCardProps {
  clone: Clone;
  onClick: () => void;
}

export const CloneCard: React.FC<CloneCardProps> = ({ clone, onClick }) => {
  const isWip = clone.status === 'wip';

  return (
    <div 
      onClick={onClick}
      className="group relative flex flex-col bg-[#0A0A0A] border border-[#1F1F22] rounded-xl overflow-hidden cursor-pointer h-full hover:border-minds-500/50 transition-all duration-300 hover:shadow-glow-purple"
    >
      {/* Top Gradient Line */}
      <div className="absolute top-0 left-0 right-0 h-[1px] bg-gradient-to-r from-transparent via-minds-500 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

      <div className="p-6 flex flex-col h-full relative z-10">
        
        {/* Header */}
        <div className="flex items-start justify-between mb-6">
          <div className="relative">
            <div className={`
              w-14 h-14 rounded-full flex items-center justify-center text-lg font-bold font-mono border
              ${isWip 
                ? 'bg-zinc-900 border-zinc-800 text-zinc-600' 
                : 'bg-zinc-900 border-zinc-700 text-zinc-300 group-hover:text-minds-400 group-hover:border-minds-500/30'}
            `}>
              {clone.avatarUrl.length > 2 ? <img src={clone.avatarUrl} className="w-full h-full rounded-full object-cover grayscale group-hover:grayscale-0 transition-all" /> : clone.avatarUrl}
            </div>
            {/* Status Dot */}
            <div className={`absolute bottom-0 right-0 w-3 h-3 rounded-full border-2 border-[#0A0A0A] ${isWip ? 'bg-zinc-700' : 'bg-emerald-500 shadow-[0_0_8px_rgba(16,185,129,0.5)]'}`} />
          </div>

          <button className="text-zinc-600 hover:text-zinc-300 transition-colors">
            <MoreHorizontal className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-grow text-center">
          <h3 className="text-lg font-bold text-zinc-200 mb-2 group-hover:text-white transition-colors">
            {clone.name}
          </h3>
          <span className="inline-block px-2 py-0.5 rounded bg-zinc-900 border border-zinc-800 text-[10px] font-bold text-minds-400 uppercase tracking-wider mb-4">
             {clone.domain}
          </span>
          <p className="text-xs text-zinc-500 font-serif leading-relaxed line-clamp-2 px-2">
            "{clone.description}"
          </p>
        </div>

        {/* Footer */}
        <div className="mt-6 pt-4 border-t border-[#1F1F22] flex items-center justify-between">
            <div className="flex items-center gap-1.5">
               <span className="px-1.5 py-0.5 rounded bg-[#151518] text-[9px] text-zinc-500 font-mono border border-zinc-800">
                   Knowledge Base
               </span>
            </div>
            
            <button 
                disabled={isWip}
                className={`
                    w-8 h-8 rounded-full flex items-center justify-center transition-all
                    ${isWip 
                        ? 'bg-zinc-900 text-zinc-700 cursor-not-allowed' 
                        : 'bg-zinc-900 text-zinc-400 hover:bg-minds-600 hover:text-white hover:shadow-[0_0_15px_rgba(139,92,246,0.4)]'}
                `}
            >
                <Play className="w-3 h-3 fill-current ml-0.5" />
            </button>
        </div>
      </div>
    </div>
  );
};