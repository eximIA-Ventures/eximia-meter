interface AuthErrorMessageProps {
  message: string
}

export function AuthErrorMessage({ message }: AuthErrorMessageProps) {
  // Map Supabase errors to user-friendly messages
  const getUserFriendlyMessage = (error: string): string => {
    const errorLower = error.toLowerCase()

    if (errorLower.includes('invalid login credentials') ||
        errorLower.includes('invalid email or password')) {
      return 'Email ou senha inválidos'
    }

    if (errorLower.includes('network') ||
        errorLower.includes('fetch')) {
      return 'Erro ao conectar. Verifique sua conexão e tente novamente.'
    }

    if (errorLower.includes('rate limit') ||
        errorLower.includes('too many requests')) {
      return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.'
    }

    // Generic fallback for security
    return 'Erro ao fazer login. Tente novamente.'
  }

  return (
    <div className="auth-error" role="alert">
      <svg
        className="auth-error-icon"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
      >
        <circle cx="12" cy="12" r="10" strokeWidth="2"/>
        <line x1="12" y1="8" x2="12" y2="12" strokeWidth="2"/>
        <line x1="12" y1="16" x2="12.01" y2="16" strokeWidth="2"/>
      </svg>
      <span>{getUserFriendlyMessage(message)}</span>
    </div>
  )
}
