# Gerencia respostas de avaliações pelos alunos
class RespostasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_avaliacao, only: [ :new, :create ]
  before_action :verificar_disponibilidade, only: [ :new, :create ]
  before_action :verificar_nao_respondeu, only: [ :new, :create ]

  # Redireciona para root
  # @return [void] Redirect para página principal
  def index
    redirect_to root_path
  end

  # Exibe formulário de resposta
  # @return [void] Renderiza form com perguntas
  def new
    @submissao = Submissao.new
    @perguntas = @avaliacao.modelo.perguntas.order(:id)

    @perguntas.each do |pergunta|
      @submissao.respostas.build(pergunta_id: pergunta.id)
    end
  end

  # Salva respostas da avaliação
  # @return [void] Redireciona para root em sucesso, form em erro
  # @efeito_colateral Cria registros Submissao e Resposta
  def create
    @submissao = Submissao.new(submissao_params)
    @submissao.avaliacao = @avaliacao
    @submissao.aluno = current_user
    @submissao.data_envio = Time.current

    @submissao.respostas.each do |resposta|
      if resposta.pergunta_id
        pergunta = Pergunta.find_by(id: resposta.pergunta_id)
        if pergunta
          resposta.snapshot_enunciado = pergunta.enunciado
          resposta.snapshot_opcoes = pergunta.opcoes
        end
      end
    end

    if @submissao.save
      redirect_to root_path, notice: "Avaliação enviada com sucesso! Obrigado pela sua participação."
    else
      @perguntas = @avaliacao.modelo.perguntas.order(:id)
      flash.now[:alert] = "Por favor, responda todas as perguntas obrigatórias."
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Encontra avaliação por ID
  # @return [Avaliacao]
  def set_avaliacao
    @avaliacao = Avaliacao.find(params[:avaliacao_id])
  end

  # Verifica se avaliação está no prazo
  # @return [void] Redireciona se expirada ou não iniciada
  def verificar_disponibilidade
    if @avaliacao.data_fim && @avaliacao.data_fim < Time.current
      redirect_to root_path, alert: "Esta avaliação já foi encerrada."
    elsif @avaliacao.data_inicio && @avaliacao.data_inicio > Time.current
      redirect_to root_path, alert: "Esta avaliação ainda não está disponível."
    end
  end

  # Verifica se aluno já respondeu
  # @return [void] Redireciona se já respondeu
  def verificar_nao_respondeu
    if Submissao.exists?(avaliacao: @avaliacao, aluno: current_user)
      redirect_to root_path, alert: "Você já respondeu esta avaliação."
    end
  end

  # Parâmetros permitidos para submissão
  # @return [ActionController::Parameters]
  def submissao_params
    params.require(:submissao).permit(
      respostas_attributes: [ :pergunta_id, :conteudo, :snapshot_enunciado, :snapshot_opcoes ]
    )
  end
end
