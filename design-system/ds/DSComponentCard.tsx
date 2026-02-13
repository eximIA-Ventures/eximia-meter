import React from 'react';
import { DSComponent, DSCategory } from '../../hooks/useDSLibrary';
import { Code, Layers, Box, Layout } from 'lucide-react';

interface DSComponentCardProps {
  component: DSComponent;
  onClick: () => void;
}

const CATEGORY_CONFIG: Record<DSCategory, { color: string; icon: typeof Code }> = {
  atoms: { color: 'text-blue-500 bg-blue-500/10 border-blue-500/20', icon: Box },
  molecules: { color: 'text-emerald-500 bg-emerald-500/10 border-emerald-500/20', icon: Layers },
  organisms: { color: 'text-amber-500 bg-amber-500/10 border-amber-500/20', icon: Code },
  templates: { color: 'text-purple-500 bg-purple-500/10 border-purple-500/20', icon: Layout },
};

export const DSComponentCard: React.FC<DSComponentCardProps> = ({ component, onClick }) => {
  const config = CATEGORY_CONFIG[component.category];
  const IconComponent = config.icon;

  return (
    <button
      onClick={onClick}
      className="w-full text-left bg-[#0A0A0A] border border-[#1F1F22] rounded-xl overflow-hidden hover:border-amber-500/30 hover:-translate-y-0.5 transition-all focus:outline-none focus:ring-2 focus:ring-amber-500/50"
    >
      {/* Preview Area */}
      <div className="h-28 bg-[#0F0F0F] border-b border-[#1F1F22] flex items-center justify-center p-4">
        <div className={`p-4 rounded-xl border ${config.color}`}>
          <IconComponent className="w-8 h-8" />
        </div>
      </div>

      {/* Info */}
      <div className="p-4">
        <h3 className="text-sm font-semibold text-white mb-1">{component.name}</h3>
        <p className="text-[11px] font-mono text-zinc-600 mb-2">{component.path}</p>
        <p className="text-xs text-zinc-500 line-clamp-2 mb-3">{component.description}</p>
        <div className="flex items-center justify-between">
          <span className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded border ${config.color}`}>
            {component.category}
          </span>
          {component.variants.length > 0 && (
            <span className="text-[10px] text-zinc-600">
              {component.variants.length} variant{component.variants.length > 1 ? 's' : ''}
            </span>
          )}
        </div>
      </div>
    </button>
  );
};

export default DSComponentCard;
