require 'rails_helper'

RSpec.describe Pergunta, type: :model do
  let(:modelo) do
    m = Modelo.new(titulo: "Modelo Teste")
    m.perguntas.build(enunciado: "Placeholder", tipo: "texto_curto")
    m.save!
    m
  end

  context "Validações Gerais" do
    it "é válida com enunciado e tipo corretos" do
      pergunta = Pergunta.new(enunciado: "Questão 1", tipo: "texto_curto", modelo: modelo)
      expect(pergunta).to be_valid
    end

    it "é inválida sem enunciado" do
      pergunta = Pergunta.new(enunciado: nil, tipo: "texto_curto", modelo: modelo)
      expect(pergunta).not_to be_valid
    end

    it "é inválida com tipo desconhecido" do
      pergunta = Pergunta.new(enunciado: "Q1", tipo: "tipo_maluco", modelo: modelo)
      expect(pergunta).not_to be_valid
    end
  end

  context "Lógica de Opções (JSON)" do
    it "lista_opcoes retorna array vazio se nil" do
      pergunta = Pergunta.new(opcoes: nil)
      expect(pergunta.lista_opcoes).to eq([])
    end

    it "lista_opcoes faz parse de string JSON" do
      pergunta = Pergunta.new(opcoes: '["A", "B"]')
      expect(pergunta.lista_opcoes).to eq(["A", "B"])
    end

    it "lista_opcoes lida com string separada por ponto e vírgula" do
      pergunta = Pergunta.new(opcoes: "Opção A; Opção B")
      expect(pergunta.lista_opcoes).to eq(["Opção A", "Opção B"])
    end
  end

  context "Validação Customizada (Refatoração)" do
    it "Múltipla escolha exige pelo menos 2 opções" do
      pergunta = Pergunta.new(
        enunciado: "Teste", 
        tipo: "multipla_escolha", 
        modelo: modelo,
        opcoes: '["Apenas Uma"]'
      )
      expect(pergunta).not_to be_valid
      expect(pergunta.errors[:opcoes]).to include("deve ter pelo menos duas opções para múltipla escolha")
    end

    it "Checkbox exige pelo menos 2 opções" do
      pergunta = Pergunta.new(
        enunciado: "Teste", 
        tipo: "checkbox", 
        modelo: modelo,
        opcoes: '[]' # Vazio
      )
      expect(pergunta).not_to be_valid
      expect(pergunta.errors[:opcoes]).to include("deve ter pelo menos duas opções para checkbox")
    end

    it "Múltipla escolha é válida com 2 opções" do
      pergunta = Pergunta.new(
        enunciado: "Teste", 
        tipo: "multipla_escolha", 
        modelo: modelo,
        opcoes: '["A", "B"]'
      )
      expect(pergunta).to be_valid
    end
  end
  
  context "Métodos Auxiliares" do
    it "tipo_humanizado retorna o nome legível" do
      pergunta = Pergunta.new(tipo: "multipla_escolha")
      expect(pergunta.tipo_humanizado).to eq("Múltipla Escolha")
    end
  end
end