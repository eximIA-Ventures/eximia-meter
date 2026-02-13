
import React, { useState } from 'react';
import { DesignSystem } from '../../types';
import { Copy, Check, Plus, Edit2, Trash2 } from 'lucide-react';

interface TokensSectionProps {
  ds: DesignSystem;
  subCategory: string;
  isEditing?: boolean;
}

const CopyButton = ({ value, className = "" }: { value: string, className?: string }) => {
    const [copied, setCopied] = useState(false);

    const handleCopy = (e: React.MouseEvent) => {
        e.stopPropagation();
        navigator.clipboard.writeText(value);
        setCopied(true);
        setTimeout(() => setCopied(false), 2000);
    };

    return (
        <button 
            onClick={handleCopy}
            className={`p-1.5 rounded-md hover:bg-zinc-800 transition-colors text-zinc-500 hover:text-white ${className}`}
            title="Copiar valor"
        >
            {copied ? <Check className="w-3 h-3 text-emerald-500" /> : <Copy className="w-3 h-3" />}
        </button>
    );
};

export const TokensSection: React.FC<TokensSectionProps> = ({ ds, subCategory, isEditing }) => {
  return (
    <div className="animate-in fade-in slide-in-from-bottom-4 duration-500 space-y-16">
      
      {/* COLORS */}
      {(subCategory === 'colors' || !subCategory) && (
      <>
        <section>
            <div className="flex items-center justify-between mb-8">
                <div className="flex items-center gap-3">
                   <div className="w-1.5 h-6 bg-amber-500 rounded-full"></div>
                   <h2 className="text-xl font-bold text-white">Cores Lendárias</h2>
                </div>
                {isEditing && (
                    <button className="flex items-center gap-2 text-xs font-bold text-amber-500 border border-amber-500/30 px-3 py-1.5 rounded-full hover:bg-amber-500/10 transition-colors">
                        <Edit2 className="w-3 h-3" /> Gerenciar Cores
                    </button>
                )}
            </div>
            
            <div className={`bg-[#0A0A0A] border rounded-2xl p-8 mb-10 ${isEditing ? 'border-amber-500/20 border-dashed' : 'border-zinc-800'}`}>
                <div className="flex flex-col md:flex-row gap-12 items-start">
                    <div className="flex-1">
                        <h3 className="font-bold text-lg text-white mb-2">Regra dos 8%</h3>
                        <p className="text-zinc-400 mb-8 text-sm leading-relaxed max-w-xl">
                            Simples. Preciso. Funcional. A cor aparece apenas quando necessária. 
                            <strong className="text-white"> 8% é o máximo que a cor ativa pode ocupar em uma tela.</strong> O restante deve ser inspirado pelo background e tipografia monocromáticos.
                        </p>
                        
                        {/* 8% Visualization Bar */}
                        <div className="mb-2 flex justify-between text-[10px] font-mono font-bold text-zinc-600 uppercase tracking-wider">
                            <span>Monocromático (92%)</span>
                            <span>Ativo (8%)</span>
                        </div>
                        <div className="h-10 w-full rounded-lg overflow-hidden flex border border-zinc-800">
                            <div className="flex-1 bg-zinc-900 flex">
                                {[...Array(10)].map((_, i) => (
                                    <div key={i} className="flex-1 border-r border-white/5 last:border-0" />
                                ))}
                            </div>
                            <div className="w-[8%] bg-amber-500" />
                        </div>
                    </div>
                    
                    <div className="w-full md:w-auto min-w-[200px]">
                         <h4 className="text-xs font-bold text-zinc-500 uppercase tracking-wider mb-4">Cor Primária Ativa</h4>
                         <div className="flex items-center gap-4 group p-4 bg-zinc-900/50 rounded-xl border border-zinc-800 relative">
                             <div className="w-12 h-12 rounded-lg bg-amber-500 shadow-lg shadow-amber-900/20" />
                             <div>
                                 <p className="font-bold text-white text-sm">{ds.tokens.colors.primary.name}</p>
                                 <div className="flex items-center gap-2 mt-1">
                                     <p className="font-mono text-xs text-zinc-500">{ds.tokens.colors.primary.hex}</p>
                                     {!isEditing && <CopyButton value={ds.tokens.colors.primary.hex} />}
                                 </div>
                             </div>
                             {isEditing && (
                                 <button className="absolute top-2 right-2 p-1 text-zinc-500 hover:text-white bg-black/50 rounded">
                                     <Edit2 className="w-3 h-3" />
                                 </button>
                             )}
                         </div>
                    </div>
                </div>
            </div>

            <div className="mb-10">
                <h4 className="text-xs font-bold text-zinc-500 uppercase tracking-widest mb-6">Escala Monocromática</h4>
                <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-6 lg:grid-cols-12 gap-3">
                    {ds.tokens.colors.scale?.map((color, idx) => (
                        <div key={idx} className="flex flex-col gap-2 group cursor-pointer relative">
                             <div 
                                className="h-14 w-full rounded-lg border border-zinc-800/50 shadow-sm transition-transform group-hover:scale-105 flex items-center justify-center relative"
                                style={{ backgroundColor: color.hex }}
                             >
                                 {!isEditing && (
                                     <div className="opacity-0 group-hover:opacity-100 bg-black/40 p-1 rounded backdrop-blur-sm">
                                         <CopyButton value={color.hex} className="text-white hover:text-white" />
                                     </div>
                                 )}
                                 {isEditing && (
                                     <div className="absolute top-1 right-1 opacity-0 group-hover:opacity-100">
                                         <div className="p-1 bg-black/50 rounded text-white"><Edit2 className="w-3 h-3"/></div>
                                     </div>
                                 )}
                             </div>
                             <div className="text-center">
                                 <p className="text-[10px] font-bold text-zinc-400 group-hover:text-white transition-colors">{color.name}</p>
                                 <p className="text-[9px] text-zinc-600 font-mono uppercase">{color.hex}</p>
                             </div>
                        </div>
                    ))}
                    {isEditing && (
                        <div className="h-14 w-full rounded-lg border-2 border-dashed border-zinc-800 flex items-center justify-center text-zinc-600 hover:text-white hover:border-zinc-600 cursor-pointer transition-colors">
                            <Plus className="w-5 h-5" />
                        </div>
                    )}
                </div>
            </div>
        </section>
      </>
      )}

      {/* TYPOGRAPHY */}
      {(subCategory === 'typography' || !subCategory) && (
        <section className={`pt-8 ${!subCategory ? 'border-t border-zinc-800' : ''}`}>
           <div className="flex items-center justify-between mb-8">
               <div className="flex items-center gap-3">
                   <div className="w-1.5 h-6 bg-indigo-500 rounded-full"></div>
                   <h2 className="text-xl font-bold text-white">Tipografia</h2>
               </div>
               {isEditing && (
                    <button className="flex items-center gap-2 text-xs font-bold text-indigo-500 border border-indigo-500/30 px-3 py-1.5 rounded-full hover:bg-indigo-500/10 transition-colors">
                        <Plus className="w-3 h-3" /> Nova Fonte
                    </button>
               )}
           </div>
           
           <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
               <div className="col-span-2 bg-[#0A0A0A] rounded-2xl border border-zinc-800 overflow-hidden">
                   <div className="p-6 border-b border-zinc-800 bg-zinc-900/30">
                       <h3 className="font-bold text-sm text-zinc-400 uppercase tracking-widest">Escala Tipográfica</h3>
                   </div>
                   {ds.tokens.typography.map((t, idx) => (
                       <div key={idx} className="flex flex-col md:flex-row md:items-baseline justify-between p-6 border-b border-zinc-800/50 last:border-0 hover:bg-zinc-900/30 transition-colors group relative">
                           <div className="mb-2 md:mb-0 w-48 shrink-0">
                               <div className="flex items-center gap-2">
                                   <p className="text-amber-500 font-bold text-xs uppercase tracking-wider mb-1">{t.role}</p>
                                   {!isEditing && <CopyButton value={`${t.size} ${t.weight}`} className="opacity-0 group-hover:opacity-100 transition-opacity" />}
                               </div>
                               <p className="text-xs text-zinc-500 font-mono">{t.size} / {t.weight}</p>
                           </div>
                           <div className="text-white w-full" style={{ 
                               fontFamily: t.font.includes('Serif') ? 'Source Serif 4' : 'Inter', 
                               fontSize: t.size, 
                               lineHeight: t.lineHeight,
                               fontWeight: t.weight.includes('Bold') ? 700 : t.weight.includes('SemiBold') ? 600 : t.weight.includes('Medium') ? 500 : 400
                            }}>
                               {t.sample}
                           </div>
                           {isEditing && (
                               <div className="absolute right-4 top-1/2 -translate-y-1/2 flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity bg-[#0A0A0A] p-1 rounded shadow-lg">
                                   <button className="p-1.5 hover:bg-zinc-800 rounded text-zinc-400 hover:text-white"><Edit2 className="w-3.5 h-3.5" /></button>
                                   <button className="p-1.5 hover:bg-rose-900/20 rounded text-zinc-400 hover:text-rose-500"><Trash2 className="w-3.5 h-3.5" /></button>
                               </div>
                           )}
                       </div>
                   ))}
               </div>
               
               <div className="space-y-6">
                   <div className={`bg-[#0A0A0A] p-8 rounded-2xl border ${isEditing ? 'border-dashed border-zinc-700' : 'border-zinc-800'} relative group`}>
                       <div className="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity">
                           {isEditing ? <Edit2 className="w-4 h-4 text-zinc-500 hover:text-white cursor-pointer" /> : <CopyButton value="font-sans" />}
                       </div>
                       <span className="text-6xl font-bold font-sans text-white block mb-4 opacity-20">Aa</span>
                       <h4 className="font-bold text-lg mb-2 text-white">Inter</h4>
                       <p className="text-sm text-zinc-500 leading-relaxed">
                           Principal font-family para UI, Títulos e Chamadas. Clareza geométrica.
                       </p>
                   </div>
                   <div className={`bg-[#0A0A0A] p-8 rounded-2xl border ${isEditing ? 'border-dashed border-zinc-700' : 'border-zinc-800'} relative group`}>
                       <div className="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity">
                           {isEditing ? <Edit2 className="w-4 h-4 text-zinc-500 hover:text-white cursor-pointer" /> : <CopyButton value="font-serif" />}
                       </div>
                       <span className="text-6xl font-serif text-white block mb-4 opacity-20">Ag</span>
                       <h4 className="font-bold text-lg font-serif mb-2 text-white">Source Serif 4</h4>
                       <p className="text-sm text-zinc-500 leading-relaxed">
                           Secundária para textos longos, parágrafos e citações. Elegância editorial.
                       </p>
                   </div>
               </div>
           </div>
        </section>
      )}

      {/* RADIUS */}
      {(subCategory === 'radius' || !subCategory) && (
        <div className={`pt-8 ${!subCategory ? 'border-t border-zinc-800' : ''}`}>
             <div className="flex items-center justify-between mb-8">
                <div className="flex items-center gap-3">
                    <div className="w-1.5 h-6 bg-pink-500 rounded-full"></div>
                    <h2 className="text-xl font-bold text-white">Border Radius</h2>
                </div>
                {isEditing && (
                    <button className="flex items-center gap-2 text-xs font-bold text-pink-500 border border-pink-500/30 px-3 py-1.5 rounded-full hover:bg-pink-500/10 transition-colors">
                        <Plus className="w-3 h-3" /> Adicionar
                    </button>
                )}
             </div>
             <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
                 {ds.tokens.radius?.map((r, idx) => (
                     <div key={idx} className="bg-[#0A0A0A] border border-zinc-800 p-8 rounded-2xl flex flex-col items-center justify-center gap-6 hover:border-zinc-600 transition-colors group relative">
                         <div className="absolute top-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity">
                             {isEditing ? <Edit2 className="w-3.5 h-3.5 text-zinc-500 hover:text-white cursor-pointer" /> : <CopyButton value={r.variable} />}
                         </div>
                         <div className="w-24 h-24 border border-white/20 bg-zinc-900 transition-all duration-300" style={{ borderRadius: r.value }}></div>
                         <div className="text-center">
                             <p className="font-mono text-xs text-white font-bold mb-1">{r.variable}</p>
                             <p className="font-mono text-[10px] text-zinc-600">{r.value}</p>
                         </div>
                     </div>
                 ))}
                 {isEditing && (
                     <div className="bg-[#0A0A0A] border-2 border-dashed border-zinc-800 p-8 rounded-2xl flex flex-col items-center justify-center gap-4 hover:border-zinc-600 transition-colors group cursor-pointer">
                         <Plus className="w-8 h-8 text-zinc-600 group-hover:text-white" />
                         <span className="text-xs font-bold text-zinc-600 group-hover:text-white">Nova Variável</span>
                     </div>
                 )}
             </div>
        </div>
      )}

      {/* SPACING */}
      {(subCategory === 'spacing' || !subCategory) && (
         <div className={`pt-8 ${!subCategory ? 'border-t border-zinc-800' : ''}`}>
             <div className="flex items-center gap-3 mb-4">
                <div className="w-1.5 h-6 bg-blue-500 rounded-full"></div>
                <h2 className="text-xl font-bold text-white">Espaçamentos</h2>
             </div>
             
             <p className="text-zinc-500 mb-10 font-serif max-w-2xl">
                 A consistência visual nasce da precisão matemática. Utilizamos um grid base de 8px para garantir ritmo vertical e horizontal.
             </p>

             <div className="space-y-2 max-w-4xl">
                 {ds.tokens.spacing.map((s, idx) => (
                     <div key={idx} className="flex items-center gap-8 group py-3 hover:bg-zinc-900/50 rounded-lg px-4 transition-colors relative">
                         {/* Value */}
                         <div className="w-12 text-right text-xs font-mono text-zinc-600 group-hover:text-zinc-300 transition-colors">
                             {s.name}
                         </div>
                         
                         {/* Visual Bar */}
                         <div className="flex-shrink-0 flex items-center">
                             <div className="w-[1px] h-6 bg-zinc-800 mr-4"></div>
                             <div
                                 className="h-6 bg-zinc-800 rounded-sm transition-all duration-300 group-hover:bg-amber-500"
                                 style={{ width: s.name }} 
                             />
                         </div>

                         {/* Token Name */}
                         <div className="flex items-center gap-4 flex-1 pl-4 border-l border-zinc-800 ml-4 h-full py-1">
                             <div className="text-xs font-bold text-zinc-500 group-hover:text-white transition-colors">
                                 {s.variable}
                             </div>
                             <div className="opacity-0 group-hover:opacity-100 transition-opacity ml-auto">
                                {isEditing ? <Edit2 className="w-3.5 h-3.5 text-zinc-500 hover:text-white cursor-pointer" /> : <CopyButton value={s.variable} />}
                             </div>
                         </div>
                     </div>
                 ))}
                 {isEditing && (
                     <div className="flex items-center gap-4 py-3 px-4 border-t border-zinc-800 border-dashed mt-2">
                         <button className="text-xs text-zinc-500 hover:text-white flex items-center gap-2">
                             <Plus className="w-3 h-3" /> Adicionar Espaçamento
                         </button>
                     </div>
                 )}
             </div>
        </div>
      )}
    </div>
  );
};
