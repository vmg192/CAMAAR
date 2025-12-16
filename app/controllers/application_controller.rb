# Controlador base para todos os controladores da aplicação
# Inclui autenticação e compatibilidade de navegador
class ApplicationController < ActionController::Base
  include Authentication
  include Authenticatable
  # Apenas permite navegadores modernos
  allow_browser versions: :modern

  # Ação padrão do index
  # @return [void]
  def index
  end
end
