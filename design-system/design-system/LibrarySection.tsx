
import React from 'react';
import { DesignSystem, DSComponent } from '../../types';
import { ComponentPreview } from './ComponentPreview';
import { Plus, GripVertical, Settings, Trash2 } from 'lucide-react';

interface LibrarySectionProps {
  ds: DesignSystem;
  filter: string;
  isEditing?: boolean;
}

export const LibrarySection: React.FC<LibrarySectionProps> = ({ ds, filter, isEditing }) => {
  const filteredComponents = filter === 'all' 
    ? ds.components 
    : ds.components.filter(c => c.type === filter);

  // Group components by type
  const grouped = filteredComponents.reduce((acc, comp) => {
    const type = comp.type;
    if (!acc[type]) acc[type] = [];
    acc[type].push(comp);
    return acc;
  }, {} as Record<string, DSComponent[]>);

  const renderGroup = (type: string, components: DSComponent[]) => (
      <section className="mb-20 last:mb-0" key={type}>
           <div className="flex items-center justify-between mb-8 pb-4 border-b border-zinc-800">
               <div className="flex items-center gap-3">
                   <h2 className="text-xl font-bold text-white uppercase tracking-widest">{type}s</h2>
                   <span className="text-xs font-mono text-zinc-600 bg-zinc-900 px-2 py-1 rounded-md">{components.length}</span>
               </div>
               {isEditing && (
                   <button className="text-xs font-bold text-zinc-500 hover:text-white flex items-center gap-2 transition-colors">
                       <Plus className="w-3 h-3" /> Novo {type}
                   </button>
               )}
           </div>
           <div className="grid grid-cols-1 xl:grid-cols-2 gap-8">
               {components.map((comp, idx) => (
                   <div key={idx} className="relative group/card animate-in fade-in slide-in-from-bottom-4 duration-500" style={{ animationDelay: `${idx * 100}ms` }}>
                       <ComponentPreview component={comp} />
                       
                       {/* Editor Controls Overlay */}
                       {isEditing && (
                           <div className="absolute -top-3 -right-3 opacity-0 group-hover/card:opacity-100 transition-opacity flex gap-2 z-20">
                               <button className="p-2 bg-zinc-800 border border-zinc-700 text-white rounded-lg shadow-xl hover:bg-zinc-700">
                                   <Settings className="w-4 h-4" />
                               </button>
                               <button className="p-2 bg-zinc-800 border border-zinc-700 text-rose-500 rounded-lg shadow-xl hover:bg-zinc-700">
                                   <Trash2 className="w-4 h-4" />
                               </button>
                           </div>
                       )}
                       {isEditing && (
                           <div className="absolute top-1/2 -translate-y-1/2 -left-8 opacity-0 group-hover/card:opacity-100 transition-opacity cursor-grab text-zinc-600 hover:text-zinc-400">
                               <GripVertical className="w-6 h-6" />
                           </div>
                       )}
                   </div>
               ))}
               
               {/* Add New Placeholder */}
               {isEditing && (
                   <div className="border-2 border-dashed border-zinc-800 rounded-xl flex flex-col items-center justify-center p-12 text-zinc-600 hover:text-white hover:border-zinc-600 cursor-pointer transition-all bg-zinc-900/20 hover:bg-zinc-900/50 min-h-[300px]">
                       <div className="w-12 h-12 rounded-full bg-zinc-800 flex items-center justify-center mb-4">
                           <Plus className="w-6 h-6" />
                       </div>
                       <span className="text-sm font-bold uppercase tracking-wider">Adicionar Componente</span>
                   </div>
               )}
           </div>
      </section>
  );

  return (
    <div className="animate-in fade-in duration-300">
      {Object.entries(grouped).map(([type, comps]) => renderGroup(type, comps as DSComponent[]))}
      {isEditing && filteredComponents.length === 0 && (
          <div className="text-center py-20 border-2 border-dashed border-zinc-800 rounded-xl">
              <p className="text-zinc-500 mb-4">Esta seção está vazia.</p>
              <button className="px-4 py-2 bg-zinc-800 text-white rounded-lg text-sm font-bold hover:bg-zinc-700">Criar Primeiro Componente</button>
          </div>
      )}
    </div>
  );
};
