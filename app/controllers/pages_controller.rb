# Controlador principal para views de dashboard
class PagesController < ApplicationController
  layout "application"

  # Exibe dashboard principal
  # @return [void] Redireciona alunos para avaliações, renderiza dashboard para admins
  def index
    if Current.session&.user && !Current.session.user.eh_admin?
      redirect_to avaliacoes_path
      nil
    end
  end
end
