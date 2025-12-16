# Módulo de autenticação para sessões
# Gerencia login, logout e verificação de autenticação
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    # Permite acesso sem autenticação
    # @param options [Hash] Opções para skip_before_action
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  # Verifica se usuário está autenticado
  # @return [Boolean]
  def authenticated?
    resume_session
  end

  # Requer autenticação ou redireciona
  # @return [Session, nil]
  def require_authentication
    resume_session || request_authentication
  end

  # Retoma sessão existente
  # @return [Session, nil]
  def resume_session
    Current.session ||= find_session_by_cookie
  end

  # Encontra sessão pelo cookie
  # @return [Session, nil]
  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  # Redireciona para login
  # @return [void]
  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  # URL para redirecionar após login
  # @return [String]
  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  # Inicia nova sessão para usuário
  # @param user [User] Usuário para autenticar
  # @return [Session] Sessão criada
  # @efeito_colateral Cria Session e define cookie
  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  # Encerra sessão atual
  # @return [void]
  # @efeito_colateral Destrói Session e remove cookie
  def terminate_session
    Current.session.destroy
    cookies.delete(:session_id)
  end
end
