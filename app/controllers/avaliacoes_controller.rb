class AvaliacoesController < ApplicationController
  allow_unauthenticated_access only: %i[ index create gestao_envios ]

  def index
    @avaliacoes = Avaliacao.all
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
    # Nota: a associação 'respostas' existe no Modelo, mesmo que a tabela esteja pendente.
    # Usamos array vazio como fallback por segurança se o BD falhar.
    begin
      @respostas = @avaliacao.respostas.includes(:aluno)
    rescue ActiveRecord::StatementInvalid
      @respostas = []
      flash.now[:alert] = "A tabela de respostas ainda não está disponível."
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
