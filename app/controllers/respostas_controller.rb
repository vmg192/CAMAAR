# app/controllers/respostas_controller.rb
class RespostasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_formulario, only: [ :new, :create ]
  before_action :verificar_disponibilidade, only: [ :new, :create ]
  before_action :verificar_nao_respondeu, only: [ :new, :create ]

  def index
    # Listagem de formulários pendentes para o aluno
    @formularios_pendentes = Formulario.joins(:turma)
      .where(turmas: { id: current_user.turma_id })
      .where("data_limite > ?", Time.current)
      .where.not(id: Resposta.where(aluno_id: current_user.id).select(:formulario_id).distinct)
      .order(data_limite: :asc)
  end

  def new
    # Tela de resposta - renderizar as questões do template
    @questoes = @formulario.questoes.order(:ordem)
    @resposta = Resposta.new
  end

  def create
    # Salvar respostas no banco
    success = true
    resposta_params[:respostas].each do |questao_id, conteudo|
      resposta = Resposta.new(
        aluno_id: current_user.id,
        formulario_id: @formulario.id,
        questao_id: questao_id,
        conteudo: conteudo
      )

      # Validar obrigatoriedade das respostas antes de salvar
      unless resposta.save
        success = false
        flash[:alert] = "Todas as questões são obrigatórias"
        break
      end
    end

    if success
      redirect_to respostas_path, notice: "Formulário respondido com sucesso!"
    else
      @questoes = @formulario.questoes.order(:ordem)
      render :new
    end
  end

  private

  def set_formulario
    @formulario = Formulario.find(params[:formulario_id])
  end

  def verificar_disponibilidade
    unless @formulario.disponivel_para_resposta?
      redirect_to respostas_path, alert: "Este formulário não está mais disponível para resposta."
    end
  end

  def verificar_nao_respondeu
    if @formulario.aluno_respondeu_tudo?(current_user.id)
      redirect_to respostas_path, alert: "Você já respondeu este formulário."
    end
  end

  def resposta_params
    params.require(:formulario).permit(respostas: {})
  end
end
