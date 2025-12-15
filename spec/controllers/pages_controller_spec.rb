require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe "GET #index" do
    context "quando não há usuário logado" do
      before do
        allow(Current).to receive(:session).and_return(nil)
      end

      it "retorna status 302" do
        get :index
        expect(response).to have_http_status(302)
      end
    end

    context "quando há um usuário admin logado" do
      let(:admin_user) do
        User.create!(
          email_address: 'admin@example.com',
          login: 'admin',
          password_digest: BCrypt::Password.create('password'),
          nome: 'Admin User',
          matricula: '987654321',
          eh_admin: true
        )
      end

      let(:session) { instance_double("Session", user: admin_user) }

      before do
        allow(admin_user).to receive(:eh_admin?).and_return(true)
        allow(Current).to receive(:session).and_return(session)
      end

      it "retorna status 200" do
        get :index
        expect(response).to have_http_status(:ok)
      end

      it "não redireciona" do
        get :index
        expect(response).not_to be_redirect
      end
    end

    context "quando há um usuário não-admin (aluno) logado" do
      let(:student_user) do
        User.create!(
          email_address: 'student@example.com',
          login: 'student',
          password_digest: BCrypt::Password.create('password'),
          nome: 'Student User',
          matricula: '123456789'
        )
      end

      let(:session) { instance_double("Session", user: student_user) }

      before do
        allow(student_user).to receive(:eh_admin?).and_return(false)
        allow(Current).to receive(:session).and_return(session)
      end

      it "redireciona para avaliacoes_path" do
        get :index
        expect(response).to redirect_to(avaliacoes_path)
      end

      it "retorna status 302" do
        get :index
        expect(response).to have_http_status(:found)
      end

      it "retorna uma resposta de redirecionamento" do
        get :index
        expect(response).to be_redirect
      end
    end

    context "quando há sessão mas sem usuário" do
      let(:session) { instance_double("Session", user: nil) }

      before do
        allow(Current).to receive(:session).and_return(session)
      end

      it "retorna status 200" do
        get :index
        expect(response).to have_http_status(:ok)
      end

      it "não redireciona" do
        get :index
        expect(response).not_to be_redirect
      end
    end
  end
end
