import React from 'react';
import { useNavigate } from 'react-router-dom';
import { DesignSystemLibrary } from '../../../components/pages/DesignSystemLibrary';

/**
 * Wrapper component for DesignSystemLibrary that provides navigation via React Router
 */
export const DesignSystemLibraryPage: React.FC = () => {
  const navigate = useNavigate();

  return (
    <DesignSystemLibrary
      onSelectDS={(dsId) => navigate(`/design-system/${dsId}`)}
    />
  );
};

export default DesignSystemLibraryPage;
