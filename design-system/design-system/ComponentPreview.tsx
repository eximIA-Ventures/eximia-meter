
import React, { useState } from 'react';
import { DSComponent } from '../../types';
import { Button } from '../atoms/Button';
import { Badge } from '../atoms/Badge';
import { SearchBar } from '../molecules/SearchBar';
import { Plus, Loader2, Target, BookOpen, Flame, Copy, Check, Code, Search } from 'lucide-react';

interface ComponentPreviewProps {
  component: DSComponent;
}

export const ComponentPreview: React.FC<ComponentPreviewProps> = ({ component }) => {
  const [copied, setCopied] = useState(false);

  const handleCopyCode = () => {
      if (component.codeSnippet) {
          navigator.clipboard.writeText(component.codeSnippet);
          setCopied(true);
          setTimeout(() => setCopied(false), 2000);
      }
  };

  // Helper to render live components based on ID
  const renderLiveComponent = () => {
    switch (component.id) {
      case 'button':
        return (
          <div className="flex flex-col gap-8 items-center w-full">
             <div className="flex flex-wrap gap-4 items-center justify-center">
                <Button variant="primary">Primary Action</Button>
                <Button variant="secondary">Secondary</Button>
                <Button variant="ghost">Ghost Button</Button>
             </div>
             <div className="flex flex-wrap gap-4 items-center justify-center">
                <Button variant="destructive">Destructive</Button>
                <Button variant="primary" icon={<Plus className="w-4 h-4"/>} className="bg-emerald-500 hover:bg-emerald-600 border-transparent text-white">Create New</Button>
             </div>
             <div className="flex gap-4 items-center">
                <Button variant="primary" icon={<Loader2 className="w-4 h-4 animate-spin"/>} className="bg-amber-500/10 text-amber-500 border-amber-500/20 hover:bg-amber-500/20">Loading</Button>
                <Button variant="secondary" disabled>Disabled</Button>
             </div>
          </div>
        );
      case 'badge':
        return (
          <div className="flex gap-8 flex-col items-center">
             <div className="flex gap-4">
                <Badge variant="default">DEFAULT</Badge>
                <Badge variant="primary">PRIMARY</Badge>
                <Badge variant="success">SUCCESS</Badge>
             </div>
             <div className="flex gap-4">
                <Badge variant="warning">WARNING</Badge>
                <Badge variant="default" className="bg-rose-950/30 text-rose-500 border-rose-900/50">ERROR</Badge>
                <Badge variant="outline">OUTLINE</Badge>
             </div>
          </div>
        );
      case 'input':
        return (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 w-full max-w-4xl text-zinc-100">
            <div className="space-y-2">
              <label className="text-xs font-bold text-zinc-500 uppercase tracking-wider">Email Address</label>
              <div className="relative">
                <input
                  type="text"
                  className="block w-full pl-10 px-4 py-3 bg-[#050505] border border-zinc-800 rounded-lg text-sm text-zinc-200 placeholder-zinc-700 focus:outline-none focus:border-zinc-600 focus:ring-1 focus:ring-zinc-600 transition-all"
                  placeholder="name@eximia.os"
                />
                 <div className="absolute left-3 top-3 text-zinc-600"><svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" /></svg></div>
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-xs font-bold text-zinc-500 uppercase tracking-wider">Search Module</label>
              <div className="relative group">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Search className="h-4 w-4 text-zinc-600" />
                  </div>
                  <input
                    type="text"
                    className="block w-full pl-10 pr-3 py-3 bg-[#050505] border border-zinc-800 rounded-lg text-sm text-zinc-200 placeholder-zinc-700 focus:outline-none focus:border-zinc-600 transition-all"
                    placeholder="Buscar por nome, tag ou categoria..."
                  />
              </div>
            </div>
             <div className="space-y-2">
              <label className="text-xs font-bold text-zinc-500 uppercase tracking-wider">Error State</label>
              <input
                  type="text"
                  className="block w-full px-4 py-3 bg-[#050505] border border-rose-900/50 rounded-lg text-sm text-rose-500 placeholder-rose-900 focus:outline-none focus:ring-1 focus:ring-rose-900 transition-all"
                  defaultValue="Invalid input data"
                />
               <span className="text-[10px] text-rose-500 font-bold uppercase tracking-wider">This field is required</span>
            </div>
             <div className="space-y-2">
              <label className="text-xs font-bold text-zinc-500 uppercase tracking-wider">Success State</label>
              <input
                  type="text"
                  className="block w-full px-4 py-3 bg-[#050505] border border-emerald-900/50 rounded-lg text-sm text-emerald-500 placeholder-emerald-900 focus:outline-none focus:ring-1 focus:ring-emerald-900 transition-all"
                  defaultValue="Valid entry"
                />
            </div>
          </div>
        );
      default:
        return <div className="p-4 border border-dashed border-zinc-800 rounded-lg text-zinc-600 text-sm bg-zinc-900/20">Preview indisponível.</div>;
    }
  };

  return (
    <div className="bg-[#09090B] border border-[#1F1F22] rounded-2xl overflow-hidden shadow-sm hover:border-zinc-700 transition-all group">
      {/* Header */}
      <div className="px-6 py-5 border-b border-[#1F1F22] flex justify-between items-center bg-[#09090B]">
          <h3 className="font-bold text-lg text-white">{component.name}</h3>
          <button 
            onClick={handleCopyCode}
            className="flex items-center gap-2 px-3 py-1.5 rounded bg-zinc-900 border border-zinc-800 text-[10px] font-bold uppercase tracking-wider text-zinc-500 hover:text-white hover:border-zinc-600 transition-colors"
          >
              {copied ? <Check className="w-3 h-3 text-emerald-500" /> : <Code className="w-3 h-3" />}
              {copied ? 'Copiado' : 'Snippet'}
          </button>
      </div>

      {/* Visual Preview Area */}
      <div className="p-10 flex items-center justify-center min-h-[240px] bg-[url('https://grainy-gradients.vercel.app/noise.svg')] bg-opacity-5 relative">
         <div className="absolute inset-0 bg-gradient-to-b from-[#09090B] to-[#050505] opacity-90" />
         <div className="relative z-10 w-full flex justify-center">
             {renderLiveComponent()}
         </div>

         {/* Sizes Preview Overlay for Buttons */}
         {component.id === 'button' && (
             <div className="absolute bottom-6 left-0 right-0 flex justify-center gap-12 text-center opacity-60">
                <div className="flex flex-col items-center gap-2">
                    <span className="px-3 py-1 rounded bg-white text-black text-[10px] font-bold">SMALL (32PX)</span>
                    <span className="text-[9px] text-zinc-600 uppercase">Size: sm</span>
                </div>
                <div className="flex flex-col items-center gap-2">
                    <span className="px-3 py-2 rounded bg-white text-black text-xs font-bold">MEDIUM (40PX)</span>
                    <span className="text-[9px] text-zinc-600 uppercase">Size: md (Default)</span>
                </div>
                 <div className="flex flex-col items-center gap-2">
                    <span className="px-4 py-3 rounded bg-white text-black text-sm font-bold">LARGE (48PX)</span>
                    <span className="text-[9px] text-zinc-600 uppercase">Size: lg</span>
                </div>
             </div>
         )}
      </div>
      
       {/* Footer / Meta */}
      <div className="px-6 py-4 bg-[#09090B] border-t border-[#1F1F22]">
         <p className="text-xs text-zinc-500 leading-relaxed font-medium">{component.description}</p>
      </div>
    </div>
  );
};
