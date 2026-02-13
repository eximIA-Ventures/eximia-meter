import React, { useState, FormEvent } from 'react';
import { Input } from '../atoms/Input';
import { Button } from '../atoms/Button';
import { AuthErrorMessage } from '../molecules/AuthErrorMessage';
import { supabase } from '../../src/lib/supabase/client';
import { Chrome } from 'lucide-react';
import toast from 'react-hot-toast';

interface LoginFormProps {
  onSubmit: (email: string, password: string) => Promise<{ error: Error | null }>;
  loading: boolean;
}

export const LoginForm: React.FC<LoginFormProps> = ({ onSubmit, loading }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [emailError, setEmailError] = useState<string>('');
  const [passwordError, setPasswordError] = useState<string>('');
  const [isOAuthLoading, setIsOAuthLoading] = useState(false);

  const validateEmail = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email) {
      setEmailError('Email é obrigatório');
      return false;
    }
    if (!emailRegex.test(email)) {
      setEmailError('Email inválido');
      return false;
    }
    setEmailError('');
    return true;
  };

  const validatePassword = (password: string): boolean => {
    if (!password) {
      setPasswordError('Senha é obrigatória');
      return false;
    }
    if (password.length < 6) {
      setPasswordError('Mínimo 6 caracteres');
      return false;
    }
    setPasswordError('');
    return true;
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);

    const isEmailValid = validateEmail(email);
    const isPasswordValid = validatePassword(password);

    if (!isEmailValid || !isPasswordValid) {
      return;
    }

    const { error: submitError } = await onSubmit(email, password);

    if (submitError) {
      setError(submitError.message);
    }
  };

  const handleGoogleLogin = async () => {
    setIsOAuthLoading(true);

    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
        queryParams: {
          access_type: 'offline',
          prompt: 'consent',
        },
      },
    });

    if (error) {
      toast.error('Erro ao conectar com Google');
      setIsOAuthLoading(false);
    }
    // OAuth redirect happens automatically, no need to set loading false
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Email Icon */}
      <Input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        onBlur={() => email && validateEmail(email)}
        placeholder="seu@email.com"
        label="Email"
        error={emailError}
        disabled={loading}
        autoComplete="email"
        size="lg"
        icon={
          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
          </svg>
        }
      />

      {/* Password Icon */}
      <Input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        onBlur={() => password && validatePassword(password)}
        placeholder="••••••••"
        label="Senha"
        error={passwordError}
        disabled={loading}
        autoComplete="current-password"
        size="lg"
        icon={
          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
          </svg>
        }
      />

      {error && <AuthErrorMessage message={error} />}

      <Button
        type="submit"
        variant="primary"
        size="lg"
        disabled={loading}
        className="w-full !bg-amber-500 hover:!bg-amber-600 !text-black shadow-[0_0_20px_rgba(245,158,11,0.25)] hover:shadow-[0_0_30px_rgba(245,158,11,0.35)]"
      >
        {loading ? 'Entrando...' : 'Entrar'}
      </Button>

      {/* Divider */}
      <div className="relative my-6">
        <div className="absolute inset-0 flex items-center">
          <div className="w-full border-t border-zinc-800" />
        </div>
        <div className="relative flex justify-center text-xs">
          <span className="px-2 bg-[#0A0A0B] text-zinc-500 uppercase tracking-wider">
            ou continue com
          </span>
        </div>
      </div>

      {/* Google OAuth Button */}
      <Button
        type="button"
        variant="secondary"
        size="lg"
        onClick={handleGoogleLogin}
        disabled={isOAuthLoading || loading}
        className="w-full"
      >
        <Chrome className="w-5 h-5 mr-2" />
        {isOAuthLoading ? 'Conectando...' : 'Google'}
      </Button>

      <div className="text-center">
        <a
          href="/forgot-password"
          className="text-xs text-zinc-500 hover:text-zinc-300 transition-colors uppercase tracking-wider font-medium"
        >
          Esqueci minha senha
        </a>
      </div>
    </form>
  );
};
