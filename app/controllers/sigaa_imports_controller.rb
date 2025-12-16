# Gerencia importação de dados SIGAA
# Acesso restrito a administradores
class SigaaImportsController < ApplicationController
  before_action :require_admin

  # Formulário de importação
  # @return [void] Renderiza form de import
  def new
  end

  # Importa dados SIGAA do class_members.json
  # @return [void] Redireciona para sucesso ou volta com erros
  # @efeito_colateral Cria registros Turma, User, MatriculaTurma
  def create
    file_path = Rails.root.join("class_members.json")
    classes_file_path = Rails.root.join("classes.json")

    unless File.exist?(file_path)
      redirect_to new_sigaa_import_path, alert: "Arquivo class_members.json não encontrado no projeto."
      return
    end

    service = SigaaImportService.new(file_path, classes_file_path)
    @results = service.process

    if @results[:errors].any?
      flash[:alert] = "Erros durante a importação: #{@results[:errors].join(', ')}"
      redirect_to new_sigaa_import_path
    else
      cache_key = "import_results_#{SecureRandom.hex(8)}"
      Rails.cache.write(cache_key, @results, expires_in: 10.minutes)
      redirect_to success_sigaa_imports_path(key: cache_key)
    end
  end

  # Atualiza banco com dados SIGAA
  # @return [void] Redireciona para sucesso ou volta com erros
  # @efeito_colateral Atualiza/cria registros Turma, User, MatriculaTurma
  def update
    file_path = Rails.root.join("class_members.json")
    classes_file_path = Rails.root.join("classes.json")

    unless File.exist?(file_path)
      redirect_to new_sigaa_import_path, alert: "Arquivo class_members.json não encontrado no projeto."
      return
    end

    service = SigaaImportService.new(file_path, classes_file_path)
    @results = service.process

    if @results[:errors].any?
      flash[:alert] = "Erros durante a atualização: #{@results[:errors].join(', ')}"
      redirect_to new_sigaa_import_path
    else
      cache_key = "import_results_#{SecureRandom.hex(8)}"
      Rails.cache.write(cache_key, @results, expires_in: 10.minutes)
      redirect_to success_sigaa_imports_path(key: cache_key)
    end
  end

  # Exibe resultados da importação
  # @return [void] Renderiza view ou redireciona se sem resultados
  # @efeito_colateral Limpa cache após exibição
  def success
    cache_key = params[:key]
    @results = Rails.cache.read(cache_key) if cache_key

    unless @results
      redirect_to root_path, alert: "Nenhum resultado de importação encontrado ou expirado."
      return
    end

    Rails.cache.delete(cache_key)
  end

  private

  # Verifica se usuário é admin
  # @return [void] Redireciona não-admins
  def require_admin
    unless Current.session&.user&.eh_admin?
      redirect_to root_path, alert: "Acesso negado. Apenas administradores podem importar dados."
    end
  end
end
