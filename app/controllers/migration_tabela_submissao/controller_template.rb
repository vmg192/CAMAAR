# app/controllers/templates_controller.rb
class TemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin
  before_action :set_template, only: [:show, :edit, :update, :destroy, :clone]
  
  # GET /templates
  def index
    @templates = Template.includes(:questaos).order(created_at: :desc)
  end
  
  # GET /templates/1
  def show
  end
  
  # GET /templates/new
  def new
    @template = Template.new
    3.times { @template.questaos.build } # Cria 3 questões em branco por padrão
  end
  
  # GET /templates/1/edit
  def edit
    @template.questaos.build if @template.questaos.empty?
  end
  
  # POST /templates
  def create
    @template = Template.new(template_params)
    
    if @template.save
      redirect_to @template, notice: 'Template criado com sucesso.'
    else
      # Garante que tenha pelo menos uma questão para mostrar no formulário
      @template.questaos.build if @template.questaos.empty?
      render :new, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /templates/1
  def update
    if @template.update(template_params)
      redirect_to @template, notice: 'Template atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  # DELETE /templates/1
  def destroy
    if @template.em_uso?
      redirect_to templates_url, alert: 'Não é possível excluir um template que está em uso.'
    else
      @template.destroy
      redirect_to templates_url, notice: 'Template excluído com sucesso.'
    end
  end
  
  # POST /templates/1/clone
  def clone
    novo_nome = "#{@template.nome} (Cópia)"
    novo_template = @template.clonar_com_questoes(novo_nome)
    
    if novo_template.persisted?
      redirect_to edit_template_path(novo_template), 
        notice: 'Template clonado com sucesso. Edite o nome se necessário.'
    else
      redirect_to @template, alert: 'Erro ao clonar template.'
    end
  end
  
  private
  
  def set_template
    @template = Template.find(params[:id])
  end
  
  def template_params
    params.require(:template).permit(
      :nome, 
      :descricao,
      questaos_attributes: [
        :id, 
        :enunciado, 
        :tipo, 
        :opcoes, 
        :ordem, 
        :_destroy
      ]
    )
  end
  
  def authorize_admin
    unless current_user.admin?
      redirect_to root_path, alert: 'Acesso restrito a administradores.'
    end
  end
end