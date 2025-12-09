class SessionsController < ApplicationController
  layout "login"
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    # Tenta autenticar por email ou por login
    user = User.authenticate_by(email_address: params[:email_address], password: params[:password]) ||
           User.authenticate_by(login: params[:email_address], password: params[:password])
    
    if user
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Login realizado com sucesso"
    else
      redirect_to new_session_path, alert: "Falha na autenticação. Usuário ou senha inválidos."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
