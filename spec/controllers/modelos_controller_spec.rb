require 'rails_helper'

RSpec.describe ModelosController, type: :controller do
  let(:valid_question_type) { "texto_curto" }

  let(:valid_attributes) {
    {
      titulo: "Modelo Válido",
      ativo: true,
      perguntas_attributes: [
        {
          enunciado: "Qual o seu nome?",
          tipo: valid_question_type,
          opcoes: [] 
        }
      ]
    }
  }

  let(:invalid_attributes) {
    { titulo: "", ativo: true }
  }

  def create_modelo(attributes = {})
    base_params = { titulo: "Modelo Persistido", ativo: true }.merge(attributes.except(:perguntas_attributes))
    modelo = Modelo.new(base_params)

    if modelo.perguntas.empty?
      modelo.perguntas.build(
        enunciado: "Pergunta Obrigatória",
        tipo: valid_question_type, 
        opcoes: []
      )
    end

    modelo.save!
    modelo
  end

  before do
    user_admin = double("User", eh_admin?: true)
    session_obj = double("Session", user: user_admin)
    allow(Current).to receive(:session).and_return(session_obj)
  end

  describe "Verificação de Permissão" do
    context "quando o usuário não é admin" do
      before do
        user_common = double("User", eh_admin?: false)
        session_obj = double("Session", user: user_common)
        allow(Current).to receive(:session).and_return(session_obj)
      end

      it "redireciona para root_path" do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Acesso restrito a administradores.")
      end
    end
  end

  describe "GET #index" do
    it "retorna resposta de sucesso (200 OK)" do
      create_modelo 
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "retorna resposta de sucesso (200 OK)" do
      modelo = create_modelo
      get :show, params: { id: modelo.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "retorna resposta de sucesso (200 OK)" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "retorna resposta de sucesso (200 OK)" do
      modelo = create_modelo
      get :edit, params: { id: modelo.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "com parâmetros válidos" do
      it "cria um novo Modelo" do
        expect {
          post :create, params: { modelo: valid_attributes }
        }.to change(Modelo, :count).by(1)
      end

      it "redireciona para o novo modelo" do
        post :create, params: { modelo: valid_attributes }
        expect(response).to redirect_to(Modelo.order(created_at: :desc).first)
        expect(flash[:notice]).to eq("Modelo criado com sucesso.")
      end
    end

    context "com parâmetros inválidos" do
      it "não cria um novo Modelo" do
        expect {
          post :create, params: { modelo: invalid_attributes }
        }.to change(Modelo, :count).by(0)
      end

      it "retorna status 422 (Unprocessable Entity)" do
        post :create, params: { modelo: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    let!(:modelo) { create_modelo }

    context "com parâmetros válidos" do
      let(:new_attributes) {
        { titulo: "Título Atualizado" }
      }

      it "atualiza o Modelo solicitado" do
        patch :update, params: { id: modelo.to_param, modelo: new_attributes }
        modelo.reload
        expect(modelo.titulo).to eq("Título Atualizado")
      end

      it "redireciona para o modelo" do
        patch :update, params: { id: modelo.to_param, modelo: new_attributes }
        expect(response).to redirect_to(modelo)
        expect(flash[:notice]).to eq("Modelo atualizado com sucesso.")
      end
    end

    context "com parâmetros inválidos" do
      it "não atualiza o título do modelo" do
        old_title = modelo.titulo
        patch :update, params: { id: modelo.to_param, modelo: invalid_attributes }
        modelo.reload
        expect(modelo.titulo).to eq(old_title)
      end

      it "retorna status 422 (Unprocessable Entity)" do
        patch :update, params: { id: modelo.to_param, modelo: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:modelo) { create_modelo }

    context "quando o modelo NÃO está em uso" do
      before do
        allow_any_instance_of(Modelo).to receive(:em_uso?).and_return(false)
      end

      it "destrói o modelo solicitado" do
        expect {
          delete :destroy, params: { id: modelo.to_param }
        }.to change(Modelo, :count).by(-1)
      end

      it "redireciona para a lista de modelos" do
        delete :destroy, params: { id: modelo.to_param }
        expect(response).to redirect_to(modelos_url)
        expect(flash[:notice]).to eq("Modelo excluído com sucesso.")
      end
    end

    context "quando o modelo ESTÁ em uso" do
      before do
        allow_any_instance_of(Modelo).to receive(:em_uso?).and_return(true)
      end

      it "NÃO destrói o modelo" do
        expect {
          delete :destroy, params: { id: modelo.to_param }
        }.to change(Modelo, :count).by(0)
      end

      it "redireciona para a lista com um alerta" do
        delete :destroy, params: { id: modelo.to_param }
        expect(response).to redirect_to(modelos_url)
        expect(flash[:alert]).to eq("Não é possível excluir um modelo que está em uso.")
      end
    end
  end

  describe "POST #clone" do
    let!(:modelo) { create_modelo }

    context "quando a clonagem é bem sucedida" do
      it "redireciona para edição do clone" do
        novo_modelo = Modelo.new(id: 999, titulo: "Clone")
        allow(novo_modelo).to receive(:persisted?).and_return(true)
        expect_any_instance_of(Modelo).to receive(:clonar_com_perguntas)
          .with("#{modelo.titulo} (Cópia)")
          .and_return(novo_modelo)

        post :clone, params: { id: modelo.to_param }

        expect(response).to redirect_to(edit_modelo_path(novo_modelo))
        expect(flash[:notice]).to include("Modelo clonado com sucesso")
      end
    end

    context "quando a clonagem falha" do
      it "redireciona para o modelo original com erro" do
        novo_modelo_falho = Modelo.new
        allow(novo_modelo_falho).to receive(:persisted?).and_return(false)

        expect_any_instance_of(Modelo).to receive(:clonar_com_perguntas)
          .and_return(novo_modelo_falho)

        post :clone, params: { id: modelo.to_param }

        expect(response).to redirect_to(modelo)
        expect(flash[:alert]).to eq("Erro ao clonar modelo.")
      end
    end
  end
end