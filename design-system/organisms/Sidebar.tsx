import React, { useState } from 'react';
import { NavLink, useLocation, useNavigate } from 'react-router-dom';
import { NavItem } from '../../types';
import {
    NAV_ITEMS_PERSONAL,
    NAV_ITEMS_BUSINESS,
    NAV_ITEMS_CREATIVE,
    NAV_ITEMS_AI,
    NAV_ITEMS_ADMIN
} from '../../constants';
import { ChevronDown, User, Settings, PanelLeftClose, PanelLeftOpen, LogOut, Sparkles, Shield } from 'lucide-react';
import { useAdminMode } from '../../hooks/useAdminMode';
import { useAuth } from '../../src/hooks/useAuth';
import { Logo } from '../atoms/Logo';

export const Sidebar: React.FC = () => {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [showUserMenu, setShowUserMenu] = useState(false);
  const { isAdmin, toggleAdmin } = useAdminMode();
  const { user, signOut } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogout = async () => {
    await signOut();
    navigate('/login');
  };

  // Check if a path is active (matches current location)
  const isPathActive = (path: string, subItems?: NavItem[]) => {
    // Exact match or starts with path (for nested routes)
    if (location.pathname === path) return true;
    if (location.pathname.startsWith(path + '/')) return true;
    // Check if any subitem is active
    if (subItems) {
      return subItems.some(sub =>
        location.pathname === sub.path ||
        location.pathname.startsWith(sub.path + '/')
      );
    }
    return false;
  };

  const renderSection = (title: string | null, items: NavItem[]) => {
      const isAISection = title === 'AI PLAYGROUND';
      const isAdminSection = title === 'ADMIN';

      return (
        <div className="mb-6">
            {title && !isCollapsed && (
                <div className="px-4 mb-3 flex items-center gap-2">
                    {isAISection ? (
                        <>
                            <Sparkles className="w-3 h-3 text-cyan-400" />
                            <span className="text-[9px] font-bold text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 to-blue-500 uppercase tracking-widest">{title}</span>
                        </>
                    ) : isAdminSection ? (
                        <>
                            <Shield className="w-3 h-3 text-amber-500" />
                            <span className="text-[9px] font-bold text-transparent bg-clip-text bg-gradient-to-r from-amber-500 to-orange-500 uppercase tracking-widest">{title}</span>
                        </>
                    ) : (
                        <span className="text-[9px] font-bold text-zinc-500 uppercase tracking-widest">{title}</span>
                    )}
                </div>
            )}
            {title && isCollapsed && (
                <div className={`my-3 border-t mx-4 ${isAISection ? 'border-cyan-500/30' : isAdminSection ? 'border-amber-500/30' : 'border-[#1F1F22]'}`} />
            )}

            <div className="space-y-1 px-2">
                {items.map((item) => (
                    <SidebarItem
                        key={item.id}
                        item={item}
                        isCollapsed={isCollapsed}
                        isActive={isPathActive(item.path, item.subItems)}
                        currentPath={location.pathname}
                        isAiItem={isAISection}
                        isAdminItem={isAdminSection}
                    />
                ))}
            </div>
        </div>
      );
  };

  return (
    <aside
      className={`
        bg-[#050505] border-r border-[#1F1F22] flex flex-col h-screen fixed left-0 top-0 z-30 font-sans transition-all duration-300 ease-in-out text-zinc-400
        ${isCollapsed ? 'w-20' : 'w-64'}
      `}
    >
      {/* 1. Header Area - Logo */}
      <div className="h-16 flex items-center px-6 border-b border-[#1F1F22]">
          <NavLink
            to="/inbox"
            className={`cursor-pointer flex items-center gap-3 group w-full ${isCollapsed ? 'justify-center' : ''}`}
          >
             {/* Logo */}
             <Logo
               size={isCollapsed ? "xl" : "lg"}
               variant={isCollapsed ? "icon" : "full"}
               className={`transition-transform duration-300 ${isCollapsed ? 'group-hover:scale-110' : ''}`}
             />
          </NavLink>
      </div>

      {/* 2. Scrollable Content */}
      <div className="flex-1 overflow-y-auto py-6 custom-scrollbar">
        {renderSection(null, NAV_ITEMS_PERSONAL)}
        {renderSection('BUSINESS', NAV_ITEMS_BUSINESS)}
        {renderSection('CREATIVE', NAV_ITEMS_CREATIVE)}
        {renderSection('AI PLAYGROUND', NAV_ITEMS_AI)}
        {isAdmin && renderSection('ADMIN', NAV_ITEMS_ADMIN)}
      </div>

      {/* 3. Footer / User Area (Inverted Order) */}
      <div className="p-4 border-t border-[#1F1F22] bg-[#050505]">

        {/* Buttons (Top) */}
        <div className={`mb-4 flex ${isCollapsed ? 'flex-col items-center gap-4' : 'justify-between px-2'}`}>
             <button
                onClick={() => setIsCollapsed(!isCollapsed)}
                className="text-zinc-600 hover:text-white transition-colors"
                aria-label={isCollapsed ? 'Expandir menu' : 'Recolher menu'}
             >
                 {isCollapsed ? <PanelLeftOpen className="w-4 h-4" /> : <PanelLeftClose className="w-4 h-4" />}
             </button>
             <div className={`flex ${isCollapsed ? 'flex-col' : ''} gap-2`}>
                 <button
                    onClick={toggleAdmin}
                    className={`transition-colors ${isAdmin ? 'text-amber-500 hover:text-amber-400' : 'text-zinc-600 hover:text-white'}`}
                    aria-label={isAdmin ? 'Desativar modo admin' : 'Ativar modo admin'}
                    title={isAdmin ? 'Admin Mode ON' : 'Admin Mode OFF'}
                 >
                     <Shield className="w-4 h-4" />
                 </button>
                 {!isCollapsed && (
                     <NavLink to="/admin/settings" className="text-zinc-600 hover:text-white transition-colors" aria-label="Configurações">
                         <Settings className="w-4 h-4" />
                     </NavLink>
                 )}
             </div>
        </div>

        {/* User Profile (Bottom) */}
        <div className="relative">
            <button
                onClick={() => setShowUserMenu(!showUserMenu)}
                className={`flex items-center gap-3 w-full rounded-lg p-2 hover:bg-[#121214] border border-transparent hover:border-[#1F1F22] transition-all ${isCollapsed ? 'justify-center' : ''}`}
            >
                <div className="w-8 h-8 rounded bg-zinc-800 border border-zinc-700 flex items-center justify-center overflow-hidden shrink-0">
                    <User className="w-4 h-4 text-zinc-400" />
                </div>
                {!isCollapsed && (
                    <div className="flex-1 min-w-0 text-left">
                        <p className="text-xs font-bold text-white truncate">{user?.email?.split('@')[0] || 'User'}</p>
                        <p className="text-[10px] text-zinc-500 truncate">{user?.email || 'Workspace'}</p>
                    </div>
                )}
            </button>

            {/* User Menu Dropdown */}
            {showUserMenu && (
                <div className={`absolute ${isCollapsed ? 'left-full ml-2' : 'bottom-full mb-2'} left-0 right-0 bg-[#121214] border border-zinc-800 rounded-lg shadow-2xl overflow-hidden z-50`}>
                    <button
                        onClick={handleLogout}
                        className="flex items-center gap-3 w-full px-4 py-3 hover:bg-rose-950/20 transition-colors text-left group"
                    >
                        <LogOut className="w-4 h-4 text-zinc-400 group-hover:text-rose-500 transition-colors" />
                        {!isCollapsed && (
                            <span className="text-xs font-medium text-zinc-300 group-hover:text-white uppercase tracking-wider">
                                Sair
                            </span>
                        )}
                    </button>
                </div>
            )}
        </div>
      </div>
    </aside>
  );
};

// Helper Item Component
const SidebarItem: React.FC<{
  item: NavItem;
  depth?: number;
  isCollapsed: boolean;
  isActive: boolean;
  currentPath: string;
  isAiItem?: boolean;
  isAdminItem?: boolean;
}> = ({ item, depth = 0, isCollapsed, isActive, currentPath, isAiItem, isAdminItem }) => {
  const [isOpen, setIsOpen] = useState(isActive);
  const hasSubs = item.subItems && item.subItems.length > 0;

  // Check if this specific item is the active one
  const isItemActive = currentPath === item.path || currentPath.startsWith(item.path + '/');

  const handleToggleSubmenu = (e: React.MouseEvent) => {
    if (hasSubs && !isCollapsed) {
      e.preventDefault();
      e.stopPropagation();
      setIsOpen(!isOpen);
    }
  };

  // Determine icon color
  const getIconColorClass = () => {
      if (isActive || isItemActive) return 'text-white';
      if (isAiItem) return 'text-minds-500 group-hover:text-minds-400';
      if (isAdminItem) return 'text-amber-500 group-hover:text-amber-400';
      return 'text-zinc-600 group-hover:text-zinc-400';
  };

  // Determine background/border for active state
  const getActiveClass = () => {
      if ((isActive && depth === 0) || isItemActive) {
          if (isAiItem) return 'text-white bg-minds-500/10 border border-minds-500/20 shadow-[0_0_15px_rgba(139,92,246,0.1)]';
          if (isAdminItem) return 'text-white bg-amber-500/10 border border-amber-500/20 shadow-[0_0_15px_rgba(245,158,11,0.1)]';
          return 'text-white bg-[#121214] border border-[#1F1F22]';
      }
      return 'text-zinc-500 hover:text-zinc-300 hover:bg-[#0A0A0A] border border-transparent';
  };

  // For items with submenus, use a button for the toggle, NavLink for navigation
  const ItemContent = () => (
    <div className={`flex items-center ${isCollapsed ? 'justify-center w-full' : 'gap-3 flex-1'}`}>
      {item.icon && (
        <item.icon className={`
            ${isCollapsed ? 'w-5 h-5' : 'w-4 h-4'}
            ${getIconColorClass()}
            transition-all duration-200
        `} />
      )}
      {!isCollapsed && (
          <span className={`uppercase tracking-wide ${(isAiItem || isAdminItem) && !isItemActive ? 'text-zinc-400 group-hover:text-white' : ''}`}>
              {item.label}
          </span>
      )}
    </div>
  );

  return (
    <div className="relative">
      {hasSubs && !isCollapsed ? (
        // Item with submenu - clickable div for toggle
        <div
          onClick={handleToggleSubmenu}
          title={isCollapsed ? item.label : undefined}
          className={`
            group flex items-center w-full py-2 px-3 rounded-lg cursor-pointer transition-all duration-200 mb-1
            ${depth > 0 ? 'pl-9 text-xs' : 'text-xs font-medium'}
            ${isCollapsed ? 'justify-center px-2' : 'justify-between'}
            ${getActiveClass()}
          `}
        >
          <ItemContent />
          <span className={`text-zinc-600 transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`}>
              <ChevronDown className="w-3 h-3" />
          </span>
        </div>
      ) : (
        // Item without submenu - NavLink for navigation
        <NavLink
          to={item.path}
          title={isCollapsed ? item.label : undefined}
          className={`
            group flex items-center w-full py-2 px-3 rounded-lg cursor-pointer transition-all duration-200 mb-1
            ${depth > 0 ? 'pl-9 text-xs' : 'text-xs font-medium'}
            ${isCollapsed ? 'justify-center px-2' : 'justify-between'}
            ${getActiveClass()}
          `}
        >
          <ItemContent />
        </NavLink>
      )}

      {/* Submenu */}
      {hasSubs && isOpen && !isCollapsed && (
        <div className="mt-1 space-y-0.5 relative">
          <div className={`absolute left-[1.15rem] top-0 bottom-2 w-[1px] ${isAiItem ? 'bg-minds-500/30' : isAdminItem ? 'bg-amber-500/30' : 'bg-[#1F1F22]'}`} />

          {item.subItems!.map((sub) => (
            <SidebarItem
              key={sub.id}
              item={sub}
              depth={depth + 1}
              isCollapsed={isCollapsed}
              isActive={false}
              currentPath={currentPath}
              isAiItem={isAiItem}
              isAdminItem={isAdminItem}
            />
          ))}
        </div>
      )}
    </div>
  );
};
