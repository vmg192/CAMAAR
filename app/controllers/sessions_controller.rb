# Gerencia sessões de autenticação (login/logout)
class SessionsController < ApplicationController
  layout "login"
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  # Exibe formulário de login
  # @return [void] Renderiza view de login
  def new
  end

  # Autentica usuário por email ou login
  # @return [void] Redireciona para root em sucesso, login em falha
  # @efeito_colateral Cria registro Session em sucesso
  def create
    user = User.authenticate_by(email_address: params[:email_address], password: params[:password]) ||
           User.authenticate_by(login: params[:email_address], password: params[:password])

    if user
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Login realizado com sucesso"
    else
      redirect_to new_session_path, alert: "Falha na autenticação. Usuário ou senha inválidos."
    end
  end

  # Encerra sessão do usuário
  # @return [void] Redireciona para página de login
  # @efeito_colateral Destrói registro Session atual
  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
