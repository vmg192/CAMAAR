# Gerencia templates de avaliação com perguntas
# Acesso restrito a administradores
class ModelosController < ApplicationController
  before_action :require_admin
  before_action :set_modelo, only: [ :show, :edit, :update, :destroy, :clone ]

  # Lista todos os templates
  # @return [void] Renderiza index com modelos
  def index
    @modelos = Modelo.includes(:perguntas).order(created_at: :desc)
  end

  # Exibe detalhes do template
  # @return [void] Renderiza view show
  def show
  end

  # Formulário para novo template
  # @return [void] Renderiza form com 3 perguntas em branco
  def new
    @modelo = Modelo.new
    3.times { @modelo.perguntas.build }
  end

  # Formulário para editar template
  # @return [void] Renderiza form de edição
  def edit
    @modelo.perguntas.build if @modelo.perguntas.empty?
  end

  # Cria novo template
  # @return [void] Redireciona para show ou renderiza form com erros
  # @efeito_colateral Cria registros Modelo e Pergunta
  def create
    @modelo = Modelo.new(modelo_params)

    if @modelo.save
      redirect_to @modelo, notice: "Modelo criado com sucesso."
    else
      @modelo.perguntas.build if @modelo.perguntas.empty?
      render :new, status: :unprocessable_entity
    end
  end

  # Atualiza template existente
  # @return [void] Redireciona para show ou renderiza form com erros
  # @efeito_colateral Atualiza registros Modelo e Pergunta
  def update
    if @modelo.update(modelo_params)
      redirect_to @modelo, notice: "Modelo atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Exclui template se não estiver em uso
  # @return [void] Redireciona para index com mensagem
  # @efeito_colateral Destrói registro Modelo se não em uso
  def destroy
    if @modelo.em_uso?
      redirect_to modelos_url, alert: "Não é possível excluir um modelo que está em uso."
    else
      @modelo.destroy
      redirect_to modelos_url, notice: "Modelo excluído com sucesso."
    end
  end

  # Duplica template com todas as perguntas
  # @return [void] Redireciona para editar template clonado
  # @efeito_colateral Cria novo Modelo com Perguntas copiadas
  def clone
    novo_titulo = "#{@modelo.titulo} (Cópia)"
    novo_modelo = @modelo.clonar_com_perguntas(novo_titulo)

    if novo_modelo.persisted?
      redirect_to edit_modelo_path(novo_modelo),
        notice: "Modelo clonado com sucesso. Edite o título se necessário."
    else
      redirect_to @modelo, alert: "Erro ao clonar modelo."
    end
  end

  private

  # Encontra modelo por ID
  # @return [Modelo]
  def set_modelo
    @modelo = Modelo.find(params[:id])
  end

  # Parâmetros permitidos para modelo
  # @return [ActionController::Parameters]
  def modelo_params
    params.require(:modelo).permit(
      :titulo,
      :ativo,
      perguntas_attributes: [
        :id,
        :enunciado,
        :tipo,
        :opcoes,
        :_destroy
      ]
    )
  end

  # Verifica se usuário é admin
  # @return [void] Redireciona não-admins
  def require_admin
    unless Current.session&.user&.eh_admin?
      redirect_to root_path, alert: "Acesso restrito a administradores."
    end
  end
end
