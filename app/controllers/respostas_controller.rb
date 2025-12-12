# app/controllers/respostas_controller.rb
class RespostasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_avaliacao, only: [ :new, :create ]
  before_action :verificar_disponibilidade, only: [ :new, :create ]
  before_action :verificar_nao_respondeu, only: [ :new, :create ]

  def index
    # Feature 109: Listagem de avaliações pendentes (já implementado em pages#index)
    redirect_to root_path
  end

  def new
    # Feature 99: Tela para responder avaliação
    @submissao = Submissao.new
    @perguntas = @avaliacao.modelo.perguntas.order(:id)

    # Pre-build respostas para nested attributes
    @perguntas.each do |pergunta|
      @submissao.respostas.build(pergunta_id: pergunta.id)
    end
  end

  def create
    # Feature 99: Salvar respostas
    @submissao = Submissao.new(submissao_params)
    @submissao.avaliacao = @avaliacao
    @submissao.aluno = current_user
    @submissao.data_envio = Time.current

    # Adicionar snapshots nas respostas
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

  def set_avaliacao
    @avaliacao = Avaliacao.find(params[:avaliacao_id])
  end

  def verificar_disponibilidade
    # Verifica se avaliação ainda está no prazo
    if @avaliacao.data_fim && @avaliacao.data_fim < Time.current
      redirect_to root_path, alert: "Esta avaliação já foi encerrada."
    elsif @avaliacao.data_inicio && @avaliacao.data_inicio > Time.current
      redirect_to root_path, alert: "Esta avaliação ainda não está disponível."
    end
  end

  def verificar_nao_respondeu
    # Verifica se aluno já respondeu
    if Submissao.exists?(avaliacao: @avaliacao, aluno: current_user)
      redirect_to root_path, alert: "Você já respondeu esta avaliação."
    end
  end

  def submissao_params
    params.require(:submissao).permit(
      respostas_attributes: [ :pergunta_id, :conteudo, :snapshot_enunciado, :snapshot_opcoes ]
    )
  end
end
