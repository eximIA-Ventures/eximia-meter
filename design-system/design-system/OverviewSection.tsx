
import React from 'react';
import { DesignSystem } from '../../types';
import { Layers, Zap, Layout, Box, PenLine } from 'lucide-react';

interface OverviewSectionProps {
  ds: DesignSystem;
  isEditing?: boolean;
}

export const OverviewSection: React.FC<OverviewSectionProps> = ({ ds, isEditing }) => (
  <div className="space-y-16 animate-in fade-in slide-in-from-bottom-4 duration-500">
    
    {/* Hero Banner */}
    <div className={`relative rounded-3xl overflow-hidden border bg-[#0A0A0A] p-12 transition-colors ${isEditing ? 'border-amber-500/30' : 'border-zinc-800'}`}>
        {isEditing && (
            <div className="absolute top-4 right-4 p-2 bg-amber-500/10 text-amber-500 rounded-lg border border-amber-500/20 cursor-pointer hover:bg-amber-500/20 transition-colors">
                <PenLine className="w-4 h-4" />
            </div>
        )}
        <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-gradient-to-b from-amber-500/10 to-transparent rounded-full blur-[100px] pointer-events-none -mr-20 -mt-20" />
        
        <div className="relative z-10 max-w-3xl">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/5 border border-white/10 mb-6">
                <span className="w-1.5 h-1.5 bg-amber-500 rounded-full animate-pulse" />
                <span className="text-[10px] font-bold text-zinc-400 uppercase tracking-wider">System Overview</span>
            </div>
            <h1 className="text-5xl font-bold text-white mb-6 leading-tight tracking-tight">
                {ds.name}
            </h1>
            <p className="text-xl text-zinc-400 font-serif leading-relaxed">
                {ds.description}
            </p>
            
            <div className="flex gap-4 mt-8">
                {ds.tags?.map(tag => (
                    <span key={tag} className="px-3 py-1.5 rounded-lg bg-zinc-900 border border-zinc-800 text-xs font-mono text-zinc-500">
                        #{tag}
                    </span>
                ))}
                {isEditing && (
                    <button className="px-3 py-1.5 rounded-lg border border-dashed border-zinc-700 text-zinc-500 text-xs font-mono hover:text-white hover:border-zinc-500 transition-colors">
                        + Add Tag
                    </button>
                )}
            </div>
        </div>
    </div>

    {/* Philosophy / Principles */}
    <div>
        <div className="flex items-center justify-between mb-8">
            <h3 className="text-sm font-bold text-zinc-500 uppercase tracking-widest flex items-center gap-2">
                <Zap className="w-4 h-4 text-amber-500" /> Core Principles
            </h3>
            {isEditing && <button className="text-xs text-amber-500 hover:underline">Edit Principles</button>}
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
           {ds.principles?.map((p, idx) => (
              <div key={idx} className={`bg-[#0A0A0A] p-8 rounded-2xl border hover:border-zinc-700 transition-colors group relative ${isEditing ? 'border-zinc-800 border-dashed' : 'border-zinc-800'}`}>
                 {isEditing && (
                     <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
                         <PenLine className="w-3 h-3 text-zinc-500 hover:text-amber-500 cursor-pointer" />
                     </div>
                 )}
                 <div className="text-zinc-600 font-mono text-xs mb-4 group-hover:text-amber-500 transition-colors">0{idx + 1}</div>
                 <h3 className="text-lg font-bold text-white mb-3">{p.name}</h3>
                 <p className="text-sm text-zinc-400 leading-relaxed font-serif italic">"{p.description}"</p>
              </div>
           ))}
           {isEditing && (
               <div className="bg-[#0A0A0A] p-8 rounded-2xl border border-zinc-800 border-dashed flex items-center justify-center cursor-pointer hover:bg-zinc-900/50 transition-colors text-zinc-600 hover:text-zinc-400">
                   <div className="flex flex-col items-center gap-2">
                       <Layout className="w-6 h-6" />
                       <span className="text-xs font-bold uppercase tracking-wider">Add Principle</span>
                   </div>
               </div>
           )}
        </div>
    </div>

    {/* Tech Stack & Stats */}
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className={`lg:col-span-2 bg-[#0A0A0A] border rounded-2xl p-8 ${isEditing ? 'border-amber-500/20' : 'border-zinc-800'}`}>
            <div className="flex justify-between mb-6">
                <h3 className="text-sm font-bold text-zinc-500 uppercase tracking-widest">Tech Stack</h3>
                {isEditing && <PenLine className="w-3.5 h-3.5 text-zinc-600 hover:text-white cursor-pointer" />}
            </div>
            <div className="flex flex-wrap gap-3">
                {ds.tech_stack?.map(tech => (
                    <div key={tech} className="px-4 py-2 bg-zinc-900 rounded-lg border border-zinc-800 text-zinc-300 text-sm font-medium flex items-center gap-2">
                        <Box className="w-3.5 h-3.5 text-zinc-500" />
                        {tech}
                    </div>
                ))}
                {isEditing && (
                    <div className="px-4 py-2 border border-dashed border-zinc-700 rounded-lg text-zinc-600 text-sm font-medium flex items-center gap-2 cursor-pointer hover:text-zinc-400">
                        <Box className="w-3.5 h-3.5" /> Add Tech
                    </div>
                )}
            </div>
        </div>
        
        <div className="bg-[#0A0A0A] border border-zinc-800 rounded-2xl p-8">
             <h3 className="text-sm font-bold text-zinc-500 uppercase tracking-widest mb-6">Stats</h3>
             <div className="space-y-4">
                 <div className="flex justify-between items-center py-2 border-b border-zinc-800/50">
                     <span className="text-zinc-400 text-sm">Components</span>
                     <span className="text-white font-mono font-bold">{ds.components.length}</span>
                 </div>
                 <div className="flex justify-between items-center py-2 border-b border-zinc-800/50">
                     <span className="text-zinc-400 text-sm">Tokens</span>
                     <span className="text-white font-mono font-bold">48</span>
                 </div>
                 <div className="flex justify-between items-center py-2">
                     <span className="text-zinc-400 text-sm">Version</span>
                     <span className="text-white font-mono font-bold">v{ds.version}</span>
                 </div>
             </div>
        </div>
    </div>
  </div>
);
