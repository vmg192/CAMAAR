class AvaliacoesController < ApplicationController
  # Requer autenticação para todas as actions

  def index
    # Se for admin, mostrar todas as avaliações
    # Se for aluno, mostrar todas as turmas matriculadas
    @turmas = []  # Inicializa como array vazio por padrão

    if current_user&.eh_admin?
      @avaliacoes = Avaliacao.all
    elsif current_user
      # Alunos veem suas turmas matriculadas
      @turmas = current_user.turmas.includes(:avaliacoes)
    else
      # Não logado - redireciona para login
      redirect_to new_session_path
    end
  end

  def gestao_envios
    @turmas = Turma.all
  end

  def create
    turma_id = params[:turma_id]
    turma = Turma.find_by(id: turma_id)

    if turma.nil?
      redirect_to gestao_envios_avaliacoes_path, alert: "Turma não encontrada."
      return
    end

    template = Modelo.find_by(titulo: "Template Padrão", ativo: true)

    if template.nil?
      redirect_to gestao_envios_avaliacoes_path, alert: "Template Padrão não encontrado. Contate o administrador."
      return
    end

    @avaliacao = Avaliacao.new(
      turma: turma,
      modelo: template,
      data_inicio: Time.current,
      data_fim: params[:data_fim].presence || 7.days.from_now
    )

    if @avaliacao.save
      redirect_to gestao_envios_avaliacoes_path, notice: "Avaliação criada com sucesso para a turma #{turma.codigo}."
    else
      redirect_to gestao_envios_avaliacoes_path, alert: "Erro ao criar avaliação: #{@avaliacao.errors.full_messages.join(', ')}"
    end
  end

  def resultados
    @avaliacao = Avaliacao.find(params[:id])
    # Pré-carrega dependências para evitar N+1.
    begin
      @submissoes = @avaliacao.submissoes.includes(:aluno, :respostas)
    rescue ActiveRecord::StatementInvalid
      @submissoes = []
      flash.now[:alert] = "Erro ao carregar submissões."
    end

    respond_to do |format|
      format.html
      format.csv do
        send_data CsvFormatterService.new(@avaliacao).generate,
                  filename: "resultados-avaliacao-#{@avaliacao.id}-#{Date.today}.csv"
      end
    end
  end
end
