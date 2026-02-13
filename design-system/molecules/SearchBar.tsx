import React from 'react';
import { Search } from 'lucide-react';

export const SearchBar: React.FC = () => {
  return (
    <div className="relative w-full max-w-md group">
      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
        <Search className="h-4 w-4 text-zinc-400 dark:text-zinc-500 group-focus-within:text-eximia-500 dark:group-focus-within:text-eximia-400 transition-colors" />
      </div>
      <input
        type="text"
        className="
          block w-full pl-10 pr-3 py-2.5 
          bg-zinc-50 dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg
          text-sm text-zinc-800 dark:text-zinc-200 placeholder-zinc-400 dark:placeholder-zinc-600
          focus:outline-none focus:border-eximia-400/50 focus:ring-1 focus:ring-eximia-400/50
          transition-all duration-200 shadow-sm
        "
        placeholder="Buscar por nome, tag ou categoria..."
      />
    </div>
  );
};