import React from 'react';

interface AuthErrorMessageProps {
  message: string;
}

const getUserFriendlyMessage = (error: string): string => {
  const errorLower = error.toLowerCase();

  if (errorLower.includes('invalid login credentials') ||
      errorLower.includes('invalid email or password')) {
    return 'Email ou senha inválidos';
  }

  if (errorLower.includes('network') ||
      errorLower.includes('fetch')) {
    return 'Erro ao conectar. Verifique sua conexão.';
  }

  if (errorLower.includes('rate limit') ||
      errorLower.includes('too many requests')) {
    return 'Muitas tentativas. Aguarde alguns minutos.';
  }

  return 'Erro ao fazer login. Tente novamente.';
};

export const AuthErrorMessage: React.FC<AuthErrorMessageProps> = ({ message }) => {
  return (
    <div className="flex items-center gap-3 p-3 rounded-lg bg-rose-950/20 border border-rose-900/30">
      <svg
        className="w-5 h-5 text-rose-500 flex-shrink-0"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth={2}
          d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
        />
      </svg>
      <span className="text-sm text-rose-400 font-medium">
        {getUserFriendlyMessage(message)}
      </span>
    </div>
  );
};
