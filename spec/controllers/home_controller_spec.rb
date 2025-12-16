require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  # Cria usuário apenas para ter um objeto válido caso a view precise
  let(:user) do
    User.create!(
      login: "user_home_final",
      email_address: "home_final@teste.com",
      matricula: "998877",
      nome: "User Home Final",
      formacao: "Docente",
      eh_admin: true,
      password: "123",
      password_confirmation: "123"
    )
  end

  before do
    # --- MOCKS DE AUTENTICAÇÃO ---

    allow(controller).to receive(:require_authentication).and_return(true)
    allow(controller).to receive(:authenticate_user!).and_return(true)

    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET #index" do
    it "retorna sucesso HTTP" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "renderiza o template index" do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
