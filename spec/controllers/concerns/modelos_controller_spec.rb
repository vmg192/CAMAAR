# spec/controllers/modelos_controller_spec.rb
require 'rails_helper'

RSpec.describe ModelosController, type: :controller do
  let(:admin_user) { create(:user, eh_admin: true) }
  let(:regular_user) { create(:user, eh_admin: false) }
  let(:modelo) { create(:modelo) }
  let(:valid_params) { { titulo: 'Modelo Teste', ativo: true } }
  let(:invalid_params) { { titulo: '', ativo: true } }

  def login_as(user)
    session = create(:session, user: user)
    allow(Current).to receive(:session).and_return(session)
  end

  describe 'Authorization' do
    it 'blocks non-admin users' do
      login_as(regular_user)
      get :index
      expect(response).to redirect_to(root_path)
    end

    it 'allows admin users' do
      login_as(admin_user)
      get :index
      expect(response).to be_successful
    end
  end

  before { login_as(admin_user) }

  describe 'GET #index' do
    it 'lists all modelos' do
      get :index
      expect(response).to be_successful
      expect(assigns(:modelos)).to be_present
    end
  end

  describe 'GET #show' do
    it 'shows a modelo' do
      get :show, params: { id: modelo.id }
      expect(response).to be_successful
      expect(assigns(:modelo)).to eq(modelo)
    end
  end

  describe 'GET #new' do
    it 'creates blank modelo with 3 perguntas' do
      get :new
      expect(assigns(:modelo).perguntas.size).to eq(3)
    end
  end

  describe 'GET #edit' do
    it 'loads modelo for editing' do
      get :edit, params: { id: modelo.id }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    it 'creates modelo with valid data' do
      expect {
        post :create, params: { modelo: valid_params }
      }.to change(Modelo, :count).by(1)
      expect(response).to redirect_to(Modelo.last)
    end

    it 'fails with invalid data' do
      post :create, params: { modelo: invalid_params }
      expect(response).to render_template(:new)
    end
  end

  describe 'PATCH #update' do
    it 'updates modelo with valid data' do
      patch :update, params: { id: modelo.id, modelo: { titulo: 'Novo Título' } }
      modelo.reload
      expect(modelo.titulo).to eq('Novo Título')
    end

    it 'fails with invalid data' do
      patch :update, params: { id: modelo.id, modelo: invalid_params }
      expect(response).to render_template(:edit)
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes when not in use' do
      allow_any_instance_of(Modelo).to receive(:em_uso?).and_return(false)
      modelo_to_delete = create(:modelo)
      expect {
        delete :destroy, params: { id: modelo_to_delete.id }
      }.to change(Modelo, :count).by(-1)
    end

    it 'blocks deletion when in use' do
      allow_any_instance_of(Modelo).to receive(:em_uso?).and_return(true)
      delete :destroy, params: { id: modelo.id }
      expect(flash[:alert]).to be_present
    end
  end

  describe 'POST #clone' do
    it 'clones modelo successfully' do
      expect {
        post :clone, params: { id: modelo.id }
      }.to change(Modelo, :count).by(1)
      expect(response).to redirect_to(edit_modelo_path(Modelo.last))
    end
  end
end