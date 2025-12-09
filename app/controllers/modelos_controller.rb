# app/controllers/modelos_controller.rb
class ModelosController < ApplicationController
  before_action :require_admin
  before_action :set_modelo, only: [:show, :edit, :update, :destroy, :clone]
  
  # GET /modelos
  def index
    @modelos = Modelo.includes(:perguntas).order(created_at: :desc)
  end
  
  # GET /modelos/1
  def show
  end
  
  # GET /modelos/new
  def new
    @modelo = Modelo.new
    3.times { @modelo.perguntas.build } # Cria 3 perguntas em branco por padrão
  end
  
  # GET /modelos/1/edit
  def edit
    @modelo.perguntas.build if @modelo.perguntas.empty?
  end
  
  # POST /modelos
  def create
    @modelo = Modelo.new(modelo_params)
    
    if @modelo.save
      redirect_to @modelo, notice: 'Modelo criado com sucesso.'
    else
      # Garante que tenha pelo menos uma pergunta para mostrar no formulário
      @modelo.perguntas.build if @modelo.perguntas.empty?
      render :new, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /modelos/1
  def update
    if @modelo.update(modelo_params)
      redirect_to @modelo, notice: 'Modelo atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  # DELETE /modelos/1
  def destroy
    if @modelo.em_uso?
      redirect_to modelos_url, alert: 'Não é possível excluir um modelo que está em uso.'
    else
      @modelo.destroy
      redirect_to modelos_url, notice: 'Modelo excluído com sucesso.'
    end
  end
  
  # POST /modelos/1/clone
  def clone
    novo_titulo = "#{@modelo.titulo} (Cópia)"
    novo_modelo = @modelo.clonar_com_perguntas(novo_titulo)
    
    if novo_modelo.persisted?
      redirect_to edit_modelo_path(novo_modelo), 
        notice: 'Modelo clonado com sucesso. Edite o título se necessário.'
    else
      redirect_to @modelo, alert: 'Erro ao clonar modelo.'
    end
  end
  
  private
  
  def set_modelo
    @modelo = Modelo.find(params[:id])
  end
  
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
  
  def require_admin
    unless Current.session&.user&.eh_admin?
      redirect_to root_path, alert: 'Acesso restrito a administradores.'
    end
  end
end
