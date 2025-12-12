class PagesController < ApplicationController
  layout "application"

  def index
    # Feature 109: Redirecionar alunos para ver suas turmas
    if Current.session&.user && !Current.session.user.eh_admin?
      redirect_to avaliacoes_path
      nil
    end

    # Admins veem dashboard admin
  end
end
