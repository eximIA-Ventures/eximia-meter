import { useState, FormEvent } from 'react'
import { Input } from '../atoms/Input'
import { Button } from '../atoms/Button'
import { AuthErrorMessage } from '../molecules/AuthErrorMessage'

interface LoginFormProps {
  onSubmit: (email: string, password: string) => Promise<{ error: Error | null }>
  loading: boolean
}

export function LoginForm({ onSubmit, loading }: LoginFormProps) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [emailError, setEmailError] = useState<string>('')
  const [passwordError, setPasswordError] = useState<string>('')

  const validateEmail = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!email) {
      setEmailError('Email é obrigatório')
      return false
    }
    if (!emailRegex.test(email)) {
      setEmailError('Email inválido')
      return false
    }
    setEmailError('')
    return true
  }

  const validatePassword = (password: string): boolean => {
    if (!password) {
      setPasswordError('Senha é obrigatória')
      return false
    }
    if (password.length < 6) {
      setPasswordError('Senha deve ter pelo menos 6 caracteres')
      return false
    }
    setPasswordError('')
    return true
  }

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setError(null)

    // Validate inputs
    const isEmailValid = validateEmail(email)
    const isPasswordValid = validatePassword(password)

    if (!isEmailValid || !isPasswordValid) {
      return
    }

    // Submit
    const { error: submitError } = await onSubmit(email, password)

    if (submitError) {
      setError(submitError.message)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="login-form">
      <div className="login-form-header">
        <h1>Bem-vindo</h1>
        <p>Faça login para continuar</p>
      </div>

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
        required
      />

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
        required
      />

      {error && <AuthErrorMessage message={error} />}

      <Button type="submit" loading={loading} className="login-form-submit">
        Entrar
      </Button>

      <div className="login-form-footer">
        <a href="/forgot-password" className="forgot-password-link">
          Esqueci minha senha
        </a>
      </div>
    </form>
  )
}
