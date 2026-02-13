import React, { useState, useEffect, useRef } from 'react';
import { DSComponent, DSCategory } from '../../hooks/useDSLibrary';
import { X, Copy, Check, Code, Box, Layers, Layout } from 'lucide-react';

interface DSComponentModalProps {
  component: DSComponent;
  onClose: () => void;
}

const CATEGORY_CONFIG: Record<DSCategory, { color: string; textColor: string }> = {
  atoms: { color: 'bg-blue-500/10 border-blue-500/20', textColor: 'text-blue-500' },
  molecules: { color: 'bg-emerald-500/10 border-emerald-500/20', textColor: 'text-emerald-500' },
  organisms: { color: 'bg-amber-500/10 border-amber-500/20', textColor: 'text-amber-500' },
  templates: { color: 'bg-purple-500/10 border-purple-500/20', textColor: 'text-purple-500' },
};

export const DSComponentModal: React.FC<DSComponentModalProps> = ({ component, onClose }) => {
  const [activeTab, setActiveTab] = useState<'preview' | 'code' | 'props'>('preview');
  const [selectedVariant, setSelectedVariant] = useState(component.variants[0]?.name || 'default');
  const [copiedIndex, setCopiedIndex] = useState<number | null>(null);
  const modalRef = useRef<HTMLDivElement>(null);

  const config = CATEGORY_CONFIG[component.category];

  // Trap focus inside modal
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onClose]);

  // Focus trap
  useEffect(() => {
    const modal = modalRef.current;
    if (modal) {
      modal.focus();
    }
  }, []);

  const handleCopy = async (code: string, index: number) => {
    try {
      await navigator.clipboard.writeText(code);
      setCopiedIndex(index);
      setTimeout(() => setCopiedIndex(null), 2000);
    } catch (err) {
      console.error('Failed to copy:', err);
    }
  };

  return (
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm"
      onClick={(e) => e.target === e.currentTarget && onClose()}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <div
        ref={modalRef}
        tabIndex={-1}
        className="w-full max-w-3xl max-h-[90vh] bg-[#0A0A0A] border border-[#1F1F22] rounded-2xl overflow-hidden flex flex-col"
      >
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b border-[#1F1F22]">
          <div>
            <h2 id="modal-title" className="text-lg font-bold text-white">{component.name}</h2>
            <p className="text-xs font-mono text-zinc-600">{component.path}</p>
          </div>
          <button
            onClick={onClose}
            className="p-2 text-zinc-400 hover:text-white hover:bg-white/5 rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-amber-500/50"
            aria-label="Fechar"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Tabs */}
        <div className="flex border-b border-[#1F1F22]">
          {(['preview', 'code', 'props'] as const).map((tab) => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`px-4 py-3 text-xs font-bold uppercase tracking-wider transition-colors ${
                activeTab === tab
                  ? 'text-white border-b-2 border-amber-500'
                  : 'text-zinc-500 hover:text-zinc-300'
              }`}
              role="tab"
              aria-selected={activeTab === tab}
            >
              {tab}
            </button>
          ))}
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-6">
          {/* Preview Tab */}
          {activeTab === 'preview' && (
            <div className="space-y-6">
              {/* Variant Selector */}
              {component.variants.length > 0 && (
                <div>
                  <label className="text-[10px] font-bold text-zinc-500 uppercase tracking-widest mb-2 block">
                    Variant
                  </label>
                  <div className="flex flex-wrap gap-2">
                    {component.variants.map((v) => (
                      <button
                        key={v.name}
                        onClick={() => setSelectedVariant(v.name)}
                        className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${
                          selectedVariant === v.name
                            ? 'bg-amber-500 text-black'
                            : 'bg-zinc-800 text-zinc-400 hover:bg-zinc-700'
                        }`}
                      >
                        {v.name}
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {/* Preview Area */}
              <div className="bg-[#050505] border border-[#1F1F22] rounded-xl p-8 flex items-center justify-center min-h-[200px]">
                <div className={`p-6 rounded-xl border ${config.color}`}>
                  <p className={`text-sm ${config.textColor}`}>
                    {component.name} ({selectedVariant})
                  </p>
                </div>
              </div>

              {/* Description */}
              <div>
                <h3 className="text-sm font-bold text-white mb-2">Descrição</h3>
                <p className="text-sm text-zinc-400">{component.description}</p>
              </div>

              {/* Variants Description */}
              {component.variants.length > 0 && (
                <div>
                  <h3 className="text-sm font-bold text-white mb-3">Variantes</h3>
                  <div className="space-y-2">
                    {component.variants.map((v) => (
                      <div key={v.name} className="flex items-center gap-3">
                        <span className="text-xs font-mono text-amber-500">{v.name}</span>
                        {v.description && (
                          <span className="text-xs text-zinc-500">{v.description}</span>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Code Tab */}
          {activeTab === 'code' && (
            <div className="space-y-4">
              {component.examples.map((example, idx) => (
                <div key={idx}>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-xs font-bold text-zinc-500">{example.title}</span>
                    <button
                      onClick={() => handleCopy(example.code, idx)}
                      className="flex items-center gap-1.5 px-2 py-1 text-[10px] font-bold text-zinc-500 hover:text-white transition-colors"
                      aria-label="Copiar código"
                    >
                      {copiedIndex === idx ? (
                        <>
                          <Check className="w-3 h-3 text-emerald-500" />
                          Copiado
                        </>
                      ) : (
                        <>
                          <Copy className="w-3 h-3" />
                          Copiar
                        </>
                      )}
                    </button>
                  </div>
                  <pre className="bg-[#050505] border border-[#1F1F22] rounded-lg p-4 overflow-x-auto" role="code">
                    <code className="text-sm font-mono text-zinc-300">{example.code}</code>
                  </pre>
                </div>
              ))}

              {component.examples.length === 0 && (
                <p className="text-sm text-zinc-500 text-center py-8">
                  Nenhum exemplo de código disponível.
                </p>
              )}
            </div>
          )}

          {/* Props Tab */}
          {activeTab === 'props' && (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-[#1F1F22]">
                    <th className="text-left py-3 px-2 text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Prop</th>
                    <th className="text-left py-3 px-2 text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Type</th>
                    <th className="text-left py-3 px-2 text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Default</th>
                    <th className="text-left py-3 px-2 text-[10px] font-bold text-zinc-500 uppercase tracking-wider">Required</th>
                  </tr>
                </thead>
                <tbody>
                  {component.props.map((prop) => (
                    <tr key={prop.name} className="border-b border-[#1F1F22]/50">
                      <td className="py-3 px-2 font-mono text-amber-500">{prop.name}</td>
                      <td className="py-3 px-2 font-mono text-zinc-400 text-xs">{prop.type}</td>
                      <td className="py-3 px-2 font-mono text-zinc-500 text-xs">{prop.defaultValue || '-'}</td>
                      <td className="py-3 px-2">
                        {prop.required ? (
                          <span className="text-amber-500">Yes</span>
                        ) : (
                          <span className="text-zinc-600">No</span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>

              {component.props.length === 0 && (
                <p className="text-sm text-zinc-500 text-center py-8">
                  Nenhuma prop documentada.
                </p>
              )}
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="flex items-center justify-between p-4 border-t border-[#1F1F22] text-xs text-zinc-600">
          <span>v{component.version}</span>
          <span>Atualizado: {component.updatedAt}</span>
        </div>
      </div>
    </div>
  );
};

export default DSComponentModal;
