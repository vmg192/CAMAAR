require 'rails_helper'

RSpec.describe "Avaliações", type: :request do
  describe "GET /gestao_envios" do
    it "retorna sucesso HTTP" do
      get gestao_envios_avaliacoes_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    let!(:turma) { Turma.create!(codigo: "CIC001", nome: "Turma de Teste", semestre: "2024.1") }
    let!(:template) { Modelo.create!(titulo: "Template Padrão", ativo: true) }

    context "com entradas válidas" do
      it "cria uma nova Avaliação vinculada ao template padrão" do
        expect {
          post avaliacoes_path, params: { turma_id: turma.id }
        }.to change(Avaliacao, :count).by(1)

        avaliacao = Avaliacao.last
        expect(avaliacao.turma).to eq(turma)
        expect(avaliacao.modelo).to eq(template)
        expect(response).to redirect_to(gestao_envios_avaliacoes_path)
        expect(flash[:notice]).to be_present
      end

      it "aceita uma data_fim personalizada" do
        data_personalizada = 2.weeks.from_now.to_date
        post avaliacoes_path, params: { turma_id: turma.id, data_fim: data_personalizada }

        avaliacao = Avaliacao.last
        expect(avaliacao.data_fim.to_date).to eq(data_personalizada)
      end
    end

    context "quando o template padrão está ausente" do
      before { template.update!(titulo: "Outro") }

      it "não cria avaliação e redireciona com alerta" do
        expect {
          post avaliacoes_path, params: { turma_id: turma.id }
        }.not_to change(Avaliacao, :count)

        expect(response).to redirect_to(gestao_envios_avaliacoes_path)
        expect(flash[:alert]).to include("Template Padrão não encontrado")
      end
    end
  end
end
