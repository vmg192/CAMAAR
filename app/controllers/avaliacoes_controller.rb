# Gerencia avaliações de turmas
# Listagem, criação e visualização de resultados
class AvaliacoesController < ApplicationController
  # Lista avaliações ou turmas do aluno
  # @return [void] Renderiza index ou redireciona para login
  def index
    @turmas = []

    if current_user&.eh_admin?
      @avaliacoes = Avaliacao.all
    elsif current_user
      @turmas = current_user.turmas.includes(:avaliacoes)
    else
      redirect_to new_session_path
    end
  end

  # View de gestão de envios (admin)
  # @return [void] Renderiza view de gestão
  def gestao_envios
    @turmas = Turma.all
  end

  # Cria nova avaliação para turma
  # @return [void] Redireciona com mensagem de sucesso/erro
  # @efeito_colateral Cria registro Avaliacao no banco
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

  # Exibe resultados com estatísticas
  # @return [void] Renderiza HTML ou download CSV
  def resultados
    @avaliacao = Avaliacao.find(params[:id])
    begin
      @submissoes = @avaliacao.submissoes.includes(:aluno, :respostas)
      @perguntas = @avaliacao.modelo.perguntas.order(:id)
      @question_stats = build_question_statistics(@avaliacao)
    rescue ActiveRecord::StatementInvalid
      @submissoes = []
      @perguntas = []
      @question_stats = {}
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

  private

  # Constrói hash de estatísticas por pergunta
  # @param avaliacao [Avaliacao] Avaliação para analisar
  # @return [Hash] Estatísticas por ID da pergunta
  def build_question_statistics(avaliacao)
    avaliacao.modelo.perguntas.each_with_object({}) do |pergunta, stats|
      respostas = Resposta.joins(:submissao)
                          .where(submissoes: { avaliacao_id: avaliacao.id })
                          .where(questao_id: pergunta.id)

      if [ "multipla_escolha", "checkbox", "escala" ].include?(pergunta.tipo)
        stats[pergunta.id] = {
          type: pergunta.tipo,
          data: respostas.group(:conteudo).count,
          total: respostas.count,
          responses: []
        }
      else
        text_responses = respostas.pluck(:conteudo).compact.reject(&:blank?)
        stats[pergunta.id] = {
          type: pergunta.tipo,
          data: {},
          total: respostas.count,
          responses: text_responses
        }
      end
    end
  end
end
