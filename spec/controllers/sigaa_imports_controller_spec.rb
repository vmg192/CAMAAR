require 'rails_helper'

RSpec.describe SigaaImportsController, type: :controller do
  let(:admin_user) do
    User.create!(
      email_address: 'admin@test.com',
      login: 'admin_test',
      password: 'password123',
      password_confirmation: 'password123',
      nome: 'Admin User',
      matricula: '000000001',
      eh_admin: true
    )
  end

  let(:regular_user) do
    User.create!(
      email_address: 'user@test.com',
      login: 'regular_test',
      password: 'password123',
      password_confirmation: 'password123',
      nome: 'Regular User',
      matricula: '000000002',
      eh_admin: false
    )
  end

  def login_as(user)
    session = Session.create!(user: user)
    cookies.signed[:session_id] = session.id
  end

  describe "GET #new" do
    context "when logged in as admin" do
      before { login_as(admin_user) }

      it "returns a successful response" do
        get :new
        expect(response).to be_successful
      end

      it "renders successfully" do
        get :new
        expect(response).to be_successful
      end
    end

    context "when logged in as regular user" do
      before { login_as(regular_user) }

      it "redirects to root path" do
        get :new
        expect(response).to redirect_to(root_path)
      end

      it "sets access denied alert" do
        get :new
        expect(flash[:alert]).to include("Acesso negado")
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        get :new
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST #create" do
    context "when logged in as admin" do
      before { login_as(admin_user) }

      context "when import succeeds" do
        before do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with(Rails.root.join("class_members.json")).and_return(true)
          allow(File).to receive(:exist?).with(Rails.root.join("classes.json")).and_return(true)
          
          mock_service = instance_double(SigaaImportService)
          allow(SigaaImportService).to receive(:new).and_return(mock_service)
          allow(mock_service).to receive(:process).and_return({
            turmas_created: 1,
            turmas_updated: 0,
            users_created: 5,
            matriculas_created: 5,
            errors: []
          })
        end

        it "processes the import and redirects to success" do
          post :create
          expect(response).to have_http_status(:redirect)
        end

        it "stores results in cache" do
          expect(Rails.cache).to receive(:write).with(anything, anything, expires_in: 10.minutes)
          post :create
        end
      end

      context "when class_members.json does not exist" do
        it "redirects to new with alert" do
          allow(File).to receive(:exist?).with(Rails.root.join("class_members.json")).and_return(false)

          post :create
          expect(response).to redirect_to(new_sigaa_import_path)
          expect(flash[:alert]).to include("não encontrado")
        end
      end

      context "when import has errors" do
        it "redirects to new with error message" do
          allow(File).to receive(:exist?).and_return(true)
          
          mock_service = instance_double(SigaaImportService)
          allow(SigaaImportService).to receive(:new).and_return(mock_service)
          allow(mock_service).to receive(:process).and_return({
            turmas_created: 0,
            users_created: 0,
            errors: ["Erro de teste"]
          })

          post :create
          expect(response).to redirect_to(new_sigaa_import_path)
          expect(flash[:alert]).to include("Erro de teste")
        end
      end
    end

    context "when logged in as regular user" do
      before { login_as(regular_user) }

      it "redirects to root path" do
        post :create
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH #update" do
    context "when logged in as admin" do
      before { login_as(admin_user) }

      context "when update succeeds" do
        before do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with(Rails.root.join("class_members.json")).and_return(true)
          allow(File).to receive(:exist?).with(Rails.root.join("classes.json")).and_return(true)
          
          mock_service = instance_double(SigaaImportService)
          allow(SigaaImportService).to receive(:new).and_return(mock_service)
          allow(mock_service).to receive(:process).and_return({
            turmas_created: 0,
            turmas_updated: 1,
            users_created: 0,
            matriculas_created: 0,
            errors: []
          })
        end

        it "processes the update and redirects to success" do
          patch :update, params: { id: 1 }
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when file does not exist" do
        it "redirects with alert" do
          allow(File).to receive(:exist?).with(Rails.root.join("class_members.json")).and_return(false)

          patch :update, params: { id: 1 }
          expect(response).to redirect_to(new_sigaa_import_path)
        end
      end
    end

    context "when logged in as regular user" do
      before { login_as(regular_user) }

      it "redirects to root path" do
        patch :update, params: { id: 1 }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET #success" do
    context "when logged in as admin" do
      before { login_as(admin_user) }

      context "with missing or expired cache key" do
        it "redirects to root when no key provided" do
          get :success
          expect(response).to redirect_to(root_path)
        end

        it "redirects to root when key is invalid" do
          get :success, params: { key: "nonexistent_key" }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to include("expirado")
        end
      end

      context "without cache key" do
        it "redirects to root with alert" do
          get :success
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context "when logged in as regular user" do
      before { login_as(regular_user) }

      it "redirects to root path" do
        get :success, params: { key: "test" }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
