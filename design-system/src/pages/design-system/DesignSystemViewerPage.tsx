import React from 'react';
import { useParams, useNavigate, Navigate } from 'react-router-dom';
import { DesignSystemViewer } from '../../../components/pages/DesignSystemViewer';

/**
 * Wrapper component for DesignSystemViewer that extracts dsId from URL params
 * and provides navigation via React Router
 */
export const DesignSystemViewerPage: React.FC = () => {
  const { dsId } = useParams<{ dsId: string }>();
  const navigate = useNavigate();

  // If no dsId in URL, redirect to design system library
  if (!dsId) {
    return <Navigate to="/design-system" replace />;
  }

  return (
    <DesignSystemViewer
      dsId={dsId}
      onBack={() => navigate('/design-system')}
      onSwitch={(newDsId) => navigate(`/design-system/${newDsId}`)}
    />
  );
};

export default DesignSystemViewerPage;
