require 'rails_helper'

RSpec.describe Authentication, type: :controller do
  controller(ApplicationController) do
    include Authentication

    def index
      render plain: 'OK'
    end

    def public_action
      render plain: 'Public'
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
  let(:session_record) do
    Session.create!(
        user: user,
        user_agent: 'Test Agent',
        ip_address: '127.0.0.1'
    )
   end

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'public_action' => 'anonymous#public_action'
      get 'new_session' => 'sessions#new', as: :new_session
      root to: 'home#index'
    end

    Current.session = nil
  end

  describe 'authentication flow' do
    context 'when user is not authenticated' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(new_session_path)
      end

      it 'stores the return URL in session' do
        get :index
        expect(session[:return_to_after_authenticating]).to be_present
      end
    end

    context 'when user is authenticated' do
      before do
        request.cookies['session_id'] = controller.send(:cookies).signed['session_id'] = session_record.id
      end

      it 'allows access to protected actions' do
        get :index
        expect(response).to have_http_status(:success)
        expect(response.body).to eq('OK')
      end
    end

    context 'when session cookie is invalid' do
      before do
        request.cookies['session_id'] = controller.send(:cookies).signed['session_id'] = 'invalid-id'
      end

      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end

    context 'when session cookie is missing' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe '.allow_unauthenticated_access' do
    controller(ApplicationController) do
      include Authentication

      allow_unauthenticated_access only: [ :public_action ]

      def index
        render plain: 'Protected'
      end

      def public_action
        render plain: 'Public'
      end
    end

    before do
      routes.draw do
        get 'public_action' => 'anonymous#public_action'
        get 'index' => 'anonymous#index'
        get 'new_session' => 'sessions#new', as: :new_session
        root to: 'home#index'
      end
    end

    it 'allows unauthenticated access to specified actions' do
      get :public_action
      expect(response).to have_http_status(:success)
      expect(response.body).to eq('Public')
    end

    it 'still requires authentication for other actions' do
      get :index
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe '#authenticated?' do
    it 'returns session when it exists' do
      request.cookies['session_id'] = controller.send(:cookies).signed['session_id'] = session_record.id

      result = controller.send(:authenticated?)
      expect(result&.id).to eq(session_record.id)
    end

    it 'returns nil when session does not exist' do
      expect(controller.send(:authenticated?)).to be_nil
    end
  end

  describe '#resume_session' do
    context 'when Current.session is already set' do
      before do
        Current.session = session_record
      end

      it 'returns the existing session' do
        expect(controller.send(:resume_session)).to eq(session_record)
      end

      it 'does not query the database' do
        expect(Session).not_to receive(:find_by)
        controller.send(:resume_session)
      end
    end

    context 'when Current.session is not set' do
      it 'finds session by cookie and sets Current.session' do
        request.cookies['session_id'] = controller.send(:cookies).signed['session_id'] = session_record.id

        result = controller.send(:resume_session)
        expect(result&.id).to eq(session_record.id)
        expect(Current.session&.id).to eq(session_record.id)
      end
    end
  end

  describe '#find_session_by_cookie' do
    it 'finds session when valid cookie exists' do
      request.cookies['session_id'] = controller.send(:cookies).signed['session_id'] = session_record.id

      result = controller.send(:find_session_by_cookie)
      expect(result&.id).to eq(session_record.id)
    end

    it 'returns nil when cookie does not exist' do
      expect(controller.send(:find_session_by_cookie)).to be_nil
    end

    it 'returns nil when session is not found' do
      request.cookies['session_id'] = controller.send(:cookies).signed['session_id'] = 'nonexistent'

      expect(controller.send(:find_session_by_cookie)).to be_nil
    end
  end

  describe '#after_authentication_url' do
    it 'returns stored return URL if present' do
      session[:return_to_after_authenticating] = 'http://example.com/protected'
      expect(controller.send(:after_authentication_url)).to eq('http://example.com/protected')
      expect(session[:return_to_after_authenticating]).to be_nil
    end

    it 'returns root URL if no return URL stored' do
      expect(controller.send(:after_authentication_url)).to eq(root_url)
    end
  end

  describe '#start_new_session_for' do
    before do
      allow(request).to receive(:user_agent).and_return('Mozilla/5.0')
      allow(request).to receive(:remote_ip).and_return('192.168.1.1')
    end

    it 'creates a new session with user agent and IP' do
      expect {
        controller.send(:start_new_session_for, user)
      }.to change { user.sessions.count }.by(1)

      new_session = user.sessions.last
      expect(new_session.user_agent).to eq('Mozilla/5.0')
      expect(new_session.ip_address).to eq('192.168.1.1')
    end

    it 'sets Current.session' do
      new_session = controller.send(:start_new_session_for, user)
      expect(Current.session).to eq(new_session)
    end

    it 'sets signed permanent cookie' do
      new_session = controller.send(:start_new_session_for, user)

      expect(controller.send(:cookies).signed[:session_id]).to eq(new_session.id)
    end

    it 'returns the created session' do
      result = controller.send(:start_new_session_for, user)
      expect(result).to be_a(Session)
      expect(result.user).to eq(user)
    end
  end

  describe '#terminate_session' do
    before do
      Current.session = session_record
      request.cookies['session_id'] = controller.send(:cookies).signed['session_id'] = session_record.id
    end

    it 'destroys the current session' do
      expect {
        controller.send(:terminate_session)
      }.to change { Session.exists?(session_record.id) }.from(true).to(false)
    end

    it 'deletes the session cookie' do
      controller.send(:terminate_session)

      expect(controller.send(:cookies).signed[:session_id]).to be_nil
    end
  end

  describe 'helper methods' do
    it 'makes authenticated? available as helper method' do
      expect(controller.class._helper_methods).to include(:authenticated?)
    end
  end

  describe 'integration scenario' do
    it 'handles complete authentication flow' do
      get :index
      expect(response).to redirect_to(new_session_path)
      stored_url = session[:return_to_after_authenticating]
      expect(stored_url).to be_present

      new_session = controller.send(:start_new_session_for, user)

      expect(new_session).to be_persisted
      expect(Current.session).to eq(new_session)

      expect(controller.send(:cookies).signed[:session_id]).to eq(new_session.id)

      Current.session = nil
      request.cookies['session_id'] = controller.send(:cookies).signed['session_id'] = new_session.id
      get :index
      expect(response).to have_http_status(:success)

      Current.session = new_session
      controller.send(:terminate_session)
      expect(controller.send(:cookies).signed[:session_id]).to be_nil
      expect(Session.exists?(new_session.id)).to be false
    end
  end
end
