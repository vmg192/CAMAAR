class SigaaImportsController < ApplicationController
  # Apenas administradores podem importar dados
  before_action :require_admin

  def new
    # Exibe formulário de upload
  end

  def create
    # Usa automaticamente o arquivo class_members.json do projeto
    file_path = Rails.root.join("class_members.json")

    unless File.exist?(file_path)
      redirect_to new_sigaa_import_path, alert: "Arquivo class_members.json não encontrado no projeto."
      return
    end

    # Processa a importação
    service = SigaaImportService.new(file_path)
    @results = service.process

    if @results[:errors].any?
      flash[:alert] = "Erros durante a importação: #{@results[:errors].join(', ')}"
      redirect_to new_sigaa_import_path
    else
      # Armazena resultados no cache (session é muito pequena para ~40 usuários)
      cache_key = "import_results_#{SecureRandom.hex(8)}"
      Rails.cache.write(cache_key, @results, expires_in: 10.minutes)

      redirect_to success_sigaa_imports_path(key: cache_key)
    end
  end

  def update
    # Usa automaticamente o arquivo class_members.json do projeto (atualização)
    file_path = Rails.root.join("class_members.json")

    unless File.exist?(file_path)
      redirect_to new_sigaa_import_path, alert: "Arquivo class_members.json não encontrado no projeto."
      return
    end

    service = SigaaImportService.new(file_path)
    @results = service.process

    if @results[:errors].any?
      flash[:alert] = "Erros durante a atualização: #{@results[:errors].join(', ')}"
      redirect_to new_sigaa_import_path
    else
      # Armazena resultados no cache (session é muito pequena para ~40 usuários)
      cache_key = "import_results_#{SecureRandom.hex(8)}"
      Rails.cache.write(cache_key, @results, expires_in: 10.minutes)

      redirect_to success_sigaa_imports_path(key: cache_key)
    end
  end

  def success
    cache_key = params[:key]
    @results = Rails.cache.read(cache_key) if cache_key

    unless @results
      redirect_to root_path, alert: "Nenhum resultado de importação encontrado ou expirado."
      return
    end

    # Limpa o cache após carregar (usuário já viu)
    Rails.cache.delete(cache_key)
  end

  private

  def require_admin
    unless Current.session&.user&.eh_admin?
      redirect_to root_path, alert: "Acesso negado. Apenas administradores podem importar dados."
    end
  end
end
