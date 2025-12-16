# Módulo com helpers de autenticação
# Fornece current_user e user_signed_in?
module Authenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_signed_in?
  end

  # Requer login ou redireciona
  # @return [void]
  def authenticate_user!
    redirect_to new_session_path, alert: "É necessário fazer login." unless user_signed_in?
  end

  # Retorna usuário atual logado
  # @return [User, nil]
  def current_user
    Current.session&.user
  end

  # Verifica se há usuário logado
  # @return [Boolean]
  def user_signed_in?
    current_user.present?
  end
end
