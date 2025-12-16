require 'rails_helper'

RSpec.describe AvaliacoesController, type: :controller do

  let(:valid_question_type) { "texto_curto" }

  def create_turma
    Turma.create!(
      codigo: "ENG-#{rand(100..999)}", 
      nome: "Engenharia de Software", 
      semestre: "2025/1"
    )
  end

  def create_template_padrao
    modelo = Modelo.new(titulo: "Template Padrão", ativo: true)
    modelo.perguntas.build(enunciado: "Pergunta Padrão", tipo: valid_question_type, opcoes: [])
    modelo.save!
    modelo
  end

  def create_modelo_generico
    modelo = Modelo.new(titulo: "Outro Modelo", ativo: true)
    modelo.perguntas.build(enunciado: "Questão 1", tipo: valid_question_type, opcoes: [])
    modelo.save!
    modelo
  end

  def create_avaliacao(turma, modelo)
    Avaliacao.create!(
      turma: turma,
      modelo: modelo,
      data_inicio: Time.current,
      data_fim: 7.days.from_now
    )
  end

  def stub_current_user(admin: false, turmas: [])
    user = double("User", eh_admin?: admin, id: 1)
    
    allow(controller).to receive(:current_user).and_return(user)
    
    session_double = double("Session", user: user)
    allow(Current).to receive(:session).and_return(session_double)
    allow(Current).to receive(:user).and_return(user)

    unless admin
      ids = turmas.map(&:id)
      relation = Turma.where(id: ids) 
      allow(user).to receive(:turmas).and_return(relation)
    end

    user
  end


  describe "GET #index" do
    context "quando o usuário NÃO está logado" do
      before do 
        allow(controller).to receive(:current_user).and_return(nil)
        allow(Current).to receive(:session).and_return(nil)
      end

      it "redireciona para o login" do
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "quando o usuário é ADMIN" do
      before { stub_current_user(admin: true) }

      it "retorna sucesso (200 OK)" do
        get :index
        expect(response).to be_successful
      end
    end

    context "quando o usuário é ALUNO" do
      let(:turma) { create_turma }
      
      before do
        stub_current_user(admin: false, turmas: [turma])
      end

      it "retorna sucesso (200 OK)" do
        get :index
        expect(response).to be_successful
      end
    end
  end

  describe "GET #gestao_envios" do
    before { stub_current_user(admin: true) }

    it "retorna sucesso e carrega a página" do
      get :gestao_envios
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    before { stub_current_user(admin: true) }
    let!(:turma) { create_turma }

    context "Cenários de Falha" do
      it "redireciona com alerta se a Turma não for encontrada" do
        post :create, params: { turma_id: 0 } 
        expect(response).to redirect_to(gestao_envios_avaliacoes_path)
        expect(flash[:alert]).to eq("Turma não encontrada.")
      end

      it "redireciona com alerta se o Template Padrão não existir" do
        Modelo.where(titulo: "Template Padrão").destroy_all
        create_modelo_generico
        
        post :create, params: { turma_id: turma.id }
        expect(response).to redirect_to(gestao_envios_avaliacoes_path)
        expect(flash[:alert]).to include("Template Padrão não encontrado")
      end
    end

    context "Cenário de Sucesso" do
      before { create_template_padrao }

      it "cria uma nova avaliação no banco" do
        expect {
          post :create, params: { turma_id: turma.id, data_fim: 5.days.from_now }
        }.to change(Avaliacao, :count).by(1)
      end

      it "redireciona com mensagem de sucesso" do
        post :create, params: { turma_id: turma.id }
        expect(response).to redirect_to(gestao_envios_avaliacoes_path)
        expect(flash[:notice]).to include("Avaliação criada com sucesso")
      end

      it "define data_fim padrão se não fornecida" do
        post :create, params: { turma_id: turma.id, data_fim: "" }
        avaliacao = Avaliacao.last
        expect(avaliacao.data_fim).to be_within(1.second).of(7.days.from_now)
      end
    end

    context "Erro de Persistência" do
      before { create_template_padrao }

      it "redireciona com alerta se o save falhar" do
        allow_any_instance_of(Avaliacao).to receive(:save).and_return(false)
        allow_any_instance_of(Avaliacao).to receive_message_chain(:errors, :full_messages).and_return(["Erro no Banco"])

        post :create, params: { turma_id: turma.id }
        expect(response).to redirect_to(gestao_envios_avaliacoes_path)
        expect(flash[:alert]).to include("Erro no Banco")
      end
    end
  end

  describe "GET #resultados" do
    before { stub_current_user(admin: true) }
    
    let!(:turma) { create_turma }
    let!(:modelo) { create_modelo_generico }
    let!(:avaliacao) { create_avaliacao(turma, modelo) }

    context "Formato HTML" do
      it "responde com sucesso (200 OK)" do
        get :resultados, params: { id: avaliacao.id }
        expect(response).to be_successful
      end

      it "lida com erro de banco de dados (StatementInvalid) sem quebrar" do
        allow(Avaliacao).to receive(:find).with(avaliacao.id.to_s).and_return(avaliacao)
        allow(avaliacao).to receive(:submissoes).and_raise(ActiveRecord::StatementInvalid)

        get :resultados, params: { id: avaliacao.id }

        expect(flash[:alert]).to eq("Erro ao carregar submissões.")
        expect(response).to be_successful
      end
      
      it "executa a lógica de estatísticas sem erro (Happy Path)" do
        get :resultados, params: { id: avaliacao.id }
        expect(response).to be_successful
      end
    end

    context "Formato CSV" do
      it "envia o arquivo gerado pelo service" do
        csv_dummy_content = "Questao,Resposta\n1,Teste"
        service_double = instance_double("CsvFormatterService")
        
        expect(CsvFormatterService).to receive(:new).with(avaliacao).and_return(service_double)
        expect(service_double).to receive(:generate).and_return(csv_dummy_content)

        get :resultados, params: { id: avaliacao.id }, format: :csv
        
        expect(response.header['Content-Type']).to include('text/csv')
        expect(response.body).to eq(csv_dummy_content)
      end
    end
  end
end