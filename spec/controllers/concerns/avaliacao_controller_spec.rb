# spec/controllers/avaliacoes_controller_spec.rb
require 'rails_helper'

RSpec.describe AvaliacoesController, type: :controller do
  let(:admin) { create(:user, eh_admin: true) }
  let(:aluno) { create(:user, eh_admin: false) }
  let(:turma) { create(:turma) }
  let(:modelo) { create(:modelo, titulo: "Template Padrão", ativo: true) }
  let(:avaliacao) { create(:avaliacao, turma: turma, modelo: modelo) }

  def login(user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'admin sees all avaliacoes' do
      login(admin)
      get :index
      expect(assigns(:avaliacoes)).to be_present
    end

    it 'student sees their turmas' do
      login(aluno)
      aluno.turmas << turma
      get :index
      expect(assigns(:turmas)).to include(turma)
    end

    it 'redirects when not logged in' do
      login(nil)
      get :index
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe 'GET #gestao_envios' do
    it 'loads turmas' do
      login(admin)
      get :gestao_envios
      expect(assigns(:turmas)).to be_present
    end
  end

  describe 'POST #create' do
    before { login(admin) }

    it 'creates avaliacao with valid data' do
      modelo
      expect {
        post :create, params: { turma_id: turma.id }
      }.to change(Avaliacao, :count).by(1)
    end

    it 'fails when turma not found' do
      post :create, params: { turma_id: 99999 }
      expect(flash[:alert]).to eq('Turma não encontrada.')
    end

    it 'fails when template not found' do
      post :create, params: { turma_id: turma.id }
      expect(flash[:alert]).to include('Template Padrão não encontrado')
    end
  end

  describe 'GET #resultados' do
    before { login(admin) }

    it 'shows results page' do
      get :resultados, params: { id: avaliacao.id }
      expect(response).to be_successful
    end

    it 'generates CSV' do
      get :resultados, params: { id: avaliacao.id }, format: :csv
      expect(response.content_type).to eq('text/csv')
    end

    it 'handles errors gracefully' do
      allow_any_instance_of(Avaliacao).to receive(:submissoes).and_raise(ActiveRecord::StatementInvalid)
      get :resultados, params: { id: avaliacao.id }
      expect(assigns(:submissoes)).to eq([])
    end
  end
end
