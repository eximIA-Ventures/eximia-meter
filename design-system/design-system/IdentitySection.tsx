
import React from 'react';
import { DesignSystem } from '../../types';
import { Sparkles, Crown, Zap, Book, Flag, Target, PenLine, Plus } from 'lucide-react';

interface IdentitySectionProps {
  ds: DesignSystem;
  isEditing?: boolean;
}

export const IdentitySection: React.FC<IdentitySectionProps> = ({ ds, isEditing }) => (
  <div className="space-y-16 animate-in slide-in-from-bottom-4 duration-500">
    
    {/* FIVU Header */}
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
       <div className={`col-span-2 bg-[#0A0A0A] p-10 rounded-2xl border relative overflow-hidden shadow-lg group ${isEditing ? 'border-amber-500/20 border-dashed' : 'border-zinc-800'}`}>
          {isEditing && (
              <button className="absolute top-4 right-4 p-2 bg-black/50 rounded-lg text-zinc-400 hover:text-white opacity-0 group-hover:opacity-100 transition-opacity">
                  <PenLine className="w-4 h-4" />
              </button>
          )}
          <div className="absolute top-0 right-0 p-10 opacity-5 pointer-events-none">
              <Sparkles className="w-40 h-40 text-white" />
          </div>
          <div className="flex items-center gap-3 mb-8">
              <div className="w-8 h-[1px] bg-amber-500"></div>
              <h4 className="text-xs font-bold text-amber-500 uppercase tracking-widest">Identidade Verbal Universal</h4>
          </div>
          <h3 className="text-2xl font-bold text-white mb-6 font-sans tracking-tight">Manifesto</h3>
          <p className="text-3xl font-serif text-zinc-300 leading-relaxed relative z-10 italic">
              "{ds.identity.mission}"
          </p>
       </div>
       
       <div className="space-y-6">
           <div className={`bg-[#0A0A0A] p-8 rounded-2xl border flex flex-col justify-center h-full relative group ${isEditing ? 'border-zinc-700 border-dashed' : 'border-zinc-800'}`}>
              {isEditing && (
                  <button className="absolute top-4 right-4 p-2 text-zinc-500 hover:text-white opacity-0 group-hover:opacity-100 transition-opacity">
                      <PenLine className="w-4 h-4" />
                  </button>
              )}
              <h4 className="text-xs font-bold text-zinc-500 uppercase tracking-widest mb-6">Metadados FIVU</h4>
              <ul className="space-y-4">
                  <li className="flex justify-between border-b border-zinc-800/50 pb-3">
                      <span className="text-sm text-zinc-500">Founder</span>
                      <span className="text-sm font-bold text-white">{ds.identity.founder || 'N/A'}</span>
                  </li>
                  <li className="flex justify-between border-b border-zinc-800/50 pb-3">
                      <span className="text-sm text-zinc-500">Since</span>
                      <span className="text-sm font-bold text-white">{ds.identity.since || '2024'}</span>
                  </li>
                  <li className="flex justify-between pb-2">
                      <span className="text-sm text-zinc-500">Corpus</span>
                      <span className="text-sm font-bold text-white font-mono">{ds.identity.corpus || 'N/A'}</span>
                  </li>
              </ul>
           </div>
       </div>
    </div>

    {/* Vision & Positioning */}
    <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div className={`bg-zinc-900/30 p-8 rounded-2xl border relative group ${isEditing ? 'border-zinc-700 border-dashed' : 'border-zinc-800'}`}>
            {isEditing && (
                <button className="absolute top-4 right-4 text-zinc-500 hover:text-white opacity-0 group-hover:opacity-100 transition-opacity">
                    <PenLine className="w-4 h-4" />
                </button>
            )}
            <h4 className="text-xs font-bold text-zinc-500 uppercase tracking-widest mb-4 flex items-center gap-2">
                <Target className="w-4 h-4" /> Visão
            </h4>
            <p className="text-lg text-zinc-300 font-serif leading-relaxed">{ds.identity.vision}</p>
        </div>
        <div className={`bg-zinc-900/30 p-8 rounded-2xl border relative group ${isEditing ? 'border-zinc-700 border-dashed' : 'border-zinc-800'}`}>
            {isEditing && (
                <button className="absolute top-4 right-4 text-zinc-500 hover:text-white opacity-0 group-hover:opacity-100 transition-opacity">
                    <PenLine className="w-4 h-4" />
                </button>
            )}
            <h4 className="text-xs font-bold text-zinc-500 uppercase tracking-widest mb-4 flex items-center gap-2">
                <Flag className="w-4 h-4" /> Posicionamento
            </h4>
            <p className="text-lg text-zinc-300 font-serif leading-relaxed">{ds.identity.positioning}</p>
        </div>
    </div>

    {/* Archetypes */}
    <div>
        <div className="flex items-center justify-between mb-8">
            <div className="flex items-center gap-3">
               <div className="w-1.5 h-6 bg-purple-500 rounded-full"></div>
               <h2 className="text-xl font-bold text-white tracking-tight">Arquétipos da Marca</h2>
            </div>
            {isEditing && (
                <button className="text-xs font-bold text-purple-500 border border-purple-500/30 px-3 py-1.5 rounded-full hover:bg-purple-500/10 transition-colors flex items-center gap-2">
                    <Plus className="w-3 h-3" /> Adicionar
                </button>
            )}
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {ds.identity.archetypes && ds.identity.archetypes.map((arch, idx) => (
                <div key={idx} className={`bg-[#0A0A0A] border p-8 rounded-2xl relative overflow-hidden group hover:border-zinc-700 transition-colors ${isEditing ? 'border-zinc-700 border-dashed' : 'border-zinc-800'}`}>
                    {isEditing && (
                        <div className="absolute top-2 right-2 flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity z-20">
                            <button className="p-1.5 bg-black/50 rounded text-zinc-400 hover:text-white"><PenLine className="w-3.5 h-3.5" /></button>
                        </div>
                    )}
                    <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
                        {idx === 0 ? <Crown className="w-24 h-24 text-white" /> : idx === 1 ? <Zap className="w-24 h-24 text-white" /> : <Book className="w-24 h-24 text-white" />}
                    </div>
                    <div className="relative z-10">
                        <span className={`inline-block px-2 py-1 rounded bg-zinc-900 border border-zinc-800 text-[10px] font-bold uppercase tracking-wider mb-4 ${idx === 0 ? 'text-amber-500' : 'text-zinc-500'}`}>
                            {idx === 0 ? 'Primário' : idx === 1 ? 'Secundário' : 'Terciário'}
                        </span>
                        <h3 className="text-2xl font-bold text-white mb-2">{arch.name}</h3>
                        <p className="text-sm text-zinc-500 mb-8 h-10">{arch.description}</p>
                        
                        <div className="space-y-4 pt-4 border-t border-zinc-800/50">
                            <div>
                                <p className="text-[10px] font-bold text-zinc-600 uppercase tracking-wider mb-1">Motivação</p>
                                <p className="text-sm font-serif italic text-zinc-300">"{arch.motivation}"</p>
                            </div>
                            <div>
                                <p className="text-[10px] font-bold text-zinc-600 uppercase tracking-wider mb-1">Manifestação</p>
                                <p className="text-sm text-zinc-400">{arch.manifestation}</p>
                            </div>
                        </div>
                    </div>
                </div>
            ))}
            {isEditing && (
                <div className="border-2 border-dashed border-zinc-800 rounded-2xl flex flex-col items-center justify-center p-8 text-zinc-600 hover:text-white hover:border-zinc-600 cursor-pointer transition-all bg-zinc-900/20">
                    <Plus className="w-8 h-8 mb-2" />
                    <span className="text-xs font-bold uppercase tracking-wider">Novo Arquétipo</span>
                </div>
            )}
        </div>
    </div>
  </div>
);
