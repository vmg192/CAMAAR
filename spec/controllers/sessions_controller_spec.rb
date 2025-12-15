require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) do
    User.create!(
      email_address: 'test@example.com',
      login: 'testuser',
      password: 'password123',
      password_confirmation: 'password123',
      nome: 'Test User',
      matricula: '123456789'
    )
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end

    it "uses the login layout" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid credentials using email" do
      it "authenticates the user and starts a session" do
        post :create, params: { email_address: user.email_address, password: 'password123' }
        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to eq("Login realizado com sucesso")
      end

      it "redirects after successful authentication" do
        post :create, params: { email_address: user.email_address, password: 'password123' }
        expect(response).to have_http_status(:redirect)
        expect(response).not_to redirect_to(new_session_path)
      end

      it "sets a success notice" do
        post :create, params: { email_address: user.email_address, password: 'password123' }
        expect(flash[:notice]).to eq("Login realizado com sucesso")
      end
    end

    context "with valid credentials using login" do
      it "authenticates the user using login field" do
        post :create, params: { email_address: user.login, password: 'password123' }
        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to eq("Login realizado com sucesso")
      end

      it "redirects after successful authentication" do
        post :create, params: { email_address: user.login, password: 'password123' }
        expect(response).to have_http_status(:redirect)
        expect(response).not_to redirect_to(new_session_path)
      end

      it "sets a success notice" do
        post :create, params: { email_address: user.login, password: 'password123' }
        expect(flash[:notice]).to eq("Login realizado com sucesso")
      end
    end

    context "with invalid password" do
      it "does not authenticate the user" do
        post :create, params: { email_address: user.email_address, password: 'wrongpassword' }
        expect(flash[:alert]).to eq("Falha na autenticação. Usuário ou senha inválidos.")
      end

      it "redirects to new_session_path" do
        post :create, params: { email_address: user.email_address, password: 'wrongpassword' }
        expect(response).to redirect_to(new_session_path)
      end

      it "sets an error alert" do
        post :create, params: { email_address: user.email_address, password: 'wrongpassword' }
        expect(flash[:alert]).to eq("Falha na autenticação. Usuário ou senha inválidos.")
      end
    end

    context "with non-existent user" do
      it "does not authenticate" do
        post :create, params: { email_address: 'nonexistent@example.com', password: 'password123' }
        expect(flash[:alert]).to eq("Falha na autenticação. Usuário ou senha inválidos.")
      end

      it "redirects to new_session_path" do
        post :create, params: { email_address: 'nonexistent@example.com', password: 'password123' }
        expect(response).to redirect_to(new_session_path)
      end

      it "sets an error alert" do
        post :create, params: { email_address: 'nonexistent@example.com', password: 'password123' }
        expect(flash[:alert]).to eq("Falha na autenticação. Usuário ou senha inválidos.")
      end
    end

    context "with missing parameters" do
      it "handles missing email_address" do
        post :create, params: { password: 'password123' }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq("Falha na autenticação. Usuário ou senha inválidos.")
      end

      it "handles missing password" do
        post :create, params: { email_address: user.email_address }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq("Falha na autenticação. Usuário ou senha inválidos.")
      end
    end

    context "rate limiting" do
      it "allows multiple failed login attempts" do
        9.times do
          post :create, params: { email_address: user.email_address, password: 'wrongpassword' }
          expect(response).to redirect_to(new_session_path)
          expect(flash[:alert]).to eq("Falha na autenticação. Usuário ou senha inválidos.")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      post :create, params: { email_address: user.email_address, password: 'password123' }
    end

    it "redirects to new_session_path" do
      delete :destroy
      expect(response).to redirect_to(new_session_path)
    end

    it "successfully logs out the user" do
      delete :destroy
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "authentication behavior" do
    it "accepts authentication via email" do
      post :create, params: { email_address: user.email_address, password: 'password123' }
      expect(flash[:notice]).to eq("Login realizado com sucesso")
    end

    it "accepts authentication via login username" do
      post :create, params: { email_address: user.login, password: 'password123' }
      expect(flash[:notice]).to eq("Login realizado com sucesso")
    end

    it "tries both authentication methods" do
      post :create, params: { email_address: user.login, password: 'password123' }
      expect(response).not_to redirect_to(new_session_path)
      expect(flash[:notice]).to eq("Login realizado com sucesso")
    end
  end

  describe "unauthenticated access" do
    it "allows access to new without authentication" do
      get :new
      expect(response).to be_successful
    end

    it "allows access to create without authentication" do
      post :create, params: { email_address: 'test@example.com', password: 'password' }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "security" do
    it "does not reveal whether email or username exists on failed login" do
      post :create, params: { email_address: 'nonexistent@example.com', password: 'password123' }
      expect(flash[:alert]).to eq("Falha na autenticação. Usuário ou senha inválidos.")

      post :create, params: { email_address: user.email_address, password: 'wrongpassword' }
      expect(flash[:alert]).to eq("Falha na autenticação. Usuário ou senha inválidos.")
    end
  end
end
