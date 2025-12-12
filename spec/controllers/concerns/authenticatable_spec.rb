require 'rails_helper'

RSpec.describe Authenticatable, type: :controller do
  controller(ApplicationController) do
    include Authenticatable

    def index
      render plain: 'Success'
    end

    def protected_action
      authenticate_user!
      render plain: 'Protected content'
    end
  end

  let(:user) do
    User.create!(
    email_address: 'test@example.com',
    login: 'test',
    password_digest: 'password',
    nome: 'nome',
    matricula: '123456789'
    )
  end
  let(:session_obj) { double('Session', user: user) }

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'protected_action' => 'anonymous#protected_action'
    end
  end

  describe '#current_user' do
    context 'when user is signed in' do
      before do
        allow(Current).to receive(:session).and_return(session_obj)
      end

      it 'returns the current user' do
        get :index
        expect(controller.current_user).to eq(user)
      end
    end

    context 'when user is not signed in' do
      before do
        allow(Current).to receive(:session).and_return(nil)
      end

      it 'returns nil' do
        get :index
        expect(controller.current_user).to be_nil
      end
    end
  end

  describe '#user_signed_in?' do
    context 'when current_user is present' do
      before do
        allow(Current).to receive(:session).and_return(session_obj)
      end

      it 'returns true' do
        get :index
        expect(controller.user_signed_in?).to be true
      end
    end

    context 'when current_user is not present' do
      before do
        allow(Current).to receive(:session).and_return(nil)
      end

      it 'returns false' do
        get :index
        expect(controller.user_signed_in?).to be false
      end
    end
  end

  describe '#authenticate_user!' do
    context 'when user is signed in' do
      before do
        allow(Current).to receive(:session).and_return(session_obj)
      end

      it 'allows access to the action' do
        get :protected_action
        expect(response).to have_http_status(:success)
        expect(response.body).to eq('Protected content')
      end
    end

    context 'when user is not signed in' do
      before do
        allow(Current).to receive(:session).and_return(nil)
      end

      it 'redirects to new_session_path' do
        get :protected_action
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'helper methods' do
    it 'makes current_user available as a helper method' do
      expect(controller.class._helper_methods).to include(:current_user)
    end

    it 'makes user_signed_in? available as a helper method' do
      expect(controller.class._helper_methods).to include(:user_signed_in?)
    end
  end
end
