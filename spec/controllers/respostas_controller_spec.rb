require 'rails_helper'

RSpec.describe RespostasController, type: :controller do
  let(:user) do
    User.create!(
      email_address: 'aluno@test.com',
      login: 'aluno_test',
      password: 'password123',
      password_confirmation: 'password123',
      nome: 'Aluno Test',
      matricula: '123456789',
      eh_admin: false
    )
  end

  let(:modelo) do
    m = Modelo.new(titulo: 'Template Test', ativo: true)
    m.perguntas.build(enunciado: 'Pergunta 1', tipo: 'escala')
    m.perguntas.build(enunciado: 'Pergunta 2', tipo: 'texto_curto')
    m.save!
    m
  end

  let(:turma) do
    Turma.create!(
      codigo: 'TEST001',
      nome: 'Turma Teste',
      semestre: '2024/1'
    )
  end

  let(:avaliacao) do
    Avaliacao.create!(
      turma: turma,
      modelo: modelo,
      data_inicio: 1.day.ago,
      data_fim: 7.days.from_now
    )
  end

  let(:avaliacao_expirada) do
    Avaliacao.create!(
      turma: turma,
      modelo: modelo,
      data_inicio: 30.days.ago,
      data_fim: 1.day.ago
    )
  end

  let(:avaliacao_futura) do
    Avaliacao.create!(
      turma: turma,
      modelo: modelo,
      data_inicio: 1.day.from_now,
      data_fim: 7.days.from_now
    )
  end

  def login_as(user)
    session = Session.create!(user: user)
    cookies.signed[:session_id] = session.id
  end

  describe "GET #index" do
    context "when logged in" do
      before { login_as(user) }

      it "redirects to root path" do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET #new" do
    context "when logged in" do
      before { login_as(user) }

      context "with valid avaliacao" do
        it "returns a successful response" do
          get :new, params: { avaliacao_id: avaliacao.id }
          expect(response).to be_successful
        end
      end

      context "with expired avaliacao" do
        it "redirects to root with alert" do
          get :new, params: { avaliacao_id: avaliacao_expirada.id }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to include("encerrada")
        end
      end

      context "with future avaliacao" do
        it "redirects to root with alert" do
          get :new, params: { avaliacao_id: avaliacao_futura.id }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to include("não está disponível")
        end
      end

      context "when user already responded" do
        before do
          Submissao.create!(
            avaliacao: avaliacao,
            aluno: user,
            data_envio: Time.current
          )
        end

        it "redirects to root with alert" do
          get :new, params: { avaliacao_id: avaliacao.id }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to include("já respondeu")
        end
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        get :new, params: { avaliacao_id: avaliacao.id }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST #create" do
    context "when logged in" do
      before { login_as(user) }

      context "with valid params" do
        let(:valid_params) do
          {
            avaliacao_id: avaliacao.id,
            submissao: {
              respostas_attributes: modelo.perguntas.each_with_index.map do |pergunta, i|
                { pergunta_id: pergunta.id, conteudo: (i + 1).to_s }
              end
            }
          }
        end

        it "creates a new submissao" do
          expect {
            post :create, params: valid_params
          }.to change(Submissao, :count).by(1)
        end

        it "creates respostas for each pergunta" do
          expect {
            post :create, params: valid_params
          }.to change(Resposta, :count).by(modelo.perguntas.count)
        end

        it "assigns the current user as aluno" do
          post :create, params: valid_params
          expect(Submissao.last.aluno).to eq(user)
        end

        it "sets the data_envio" do
          post :create, params: valid_params
          expect(Submissao.last.data_envio).not_to be_nil
        end

        it "redirects to root with success notice" do
          post :create, params: valid_params
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to include("sucesso")
        end

        it "saves snapshot of pergunta enunciado" do
          post :create, params: valid_params
          resposta = Resposta.last
          expect(resposta.snapshot_enunciado).not_to be_nil
        end
      end

      context "with missing submissao params" do
        it "handles missing params gracefully" do
          expect {
            post :create, params: { avaliacao_id: avaliacao.id }
          }.to raise_error(ActionController::ParameterMissing)
        end
      end

      context "with expired avaliacao" do
        it "redirects to root with alert" do
          post :create, params: {
            avaliacao_id: avaliacao_expirada.id,
            submissao: { respostas_attributes: [] }
          }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to include("encerrada")
        end
      end

      context "when user already responded" do
        before do
          Submissao.create!(
            avaliacao: avaliacao,
            aluno: user,
            data_envio: Time.current
          )
        end

        it "redirects to root with alert" do
          post :create, params: {
            avaliacao_id: avaliacao.id,
            submissao: { respostas_attributes: [] }
          }
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to include("já respondeu")
        end
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        post :create, params: { avaliacao_id: avaliacao.id, submissao: {} }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
