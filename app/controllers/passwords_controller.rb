# Gerencia recuperação de senha
class PasswordsController < ApplicationController
  layout "login"
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  # Formulário para solicitar reset
  # @return [void] Renderiza form de email
  def new
  end

  # Envia email de reset de senha
  # @return [void] Redireciona para login com aviso
  # @efeito_colateral Envia email se usuário existir
  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
  end

  # Formulário para nova senha
  # @return [void] Renderiza form de senha
  def edit
  end

  # Atualiza senha do usuário
  # @return [void] Redireciona para login em sucesso, form em erro
  # @efeito_colateral Atualiza senha no banco
  def update
    if @user.update(params.permit(:password, :password_confirmation))
      redirect_to new_session_path, notice: "Password has been reset."
    else
      redirect_to edit_password_path(params[:token]), alert: "Passwords did not match."
    end
  end

  private

  # Encontra usuário pelo token de reset
  # @return [User] Usuário correspondente ao token
  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
  end
end
