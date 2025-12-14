require 'rails_helper'

RSpec.describe Modelo, type: :model do
  # Configuração básica para os testes
  let(:valid_attributes) { { titulo: "Modelo Teste", ativo: true } }
  let(:pergunta_attributes) { { enunciado: "Pergunta 1", tipo: "texto_curto" } }

  # Cria um modelo válido no banco para reuso
  let(:modelo_existente) do
    m = Modelo.new(valid_attributes)
    m.perguntas.build(pergunta_attributes)
    m.save!
    m
  end

  context "Validações e Atributos" do
    it "é válido com título e perguntas" do
      modelo = Modelo.new(valid_attributes)
      modelo.perguntas.build(pergunta_attributes)
      expect(modelo).to be_valid
    end

    it "é inválido sem título" do
      modelo = Modelo.new(valid_attributes.merge(titulo: nil))
      modelo.perguntas.build(pergunta_attributes)
      expect(modelo).not_to be_valid
      expect(modelo.errors[:titulo]).to include("can't be blank")
    end

    it "valida unicidade do título (case sensitive)" do
      # Cria o primeiro
      modelo_existente
      
      # Tenta criar o segundo igual
      duplicado = Modelo.new(valid_attributes)
      duplicado.perguntas.build(pergunta_attributes)
      expect(duplicado).not_to be_valid
      expect(duplicado.errors[:titulo]).to include("has already been taken")
    end

    it "aceita atributos aninhados para perguntas" do
      modelo = Modelo.new(titulo: "Nested Attrs")
      modelo.perguntas_attributes = [pergunta_attributes]
      expect(modelo).to be_valid
      expect(modelo.perguntas.size).to eq(1)
    end
  end

  context "Regras de Negócio de Perguntas" do
    it "CREATE: impede criar modelo sem perguntas" do
      modelo = Modelo.new(valid_attributes)
      # Não adicionamos perguntas
      expect(modelo).not_to be_valid
      expect(modelo.errors[:base]).to include("Um modelo deve ter pelo menos uma pergunta")
    end

    it "UPDATE: impede remover todas as perguntas de um modelo existente" do
      modelo = modelo_existente
      pergunta = modelo.perguntas.first
      
      # Tenta marcar a única pergunta para destruição
      pergunta.mark_for_destruction
      
      expect(modelo).not_to be_valid
      expect(modelo.errors[:base]).to include("Não é possível remover todas as perguntas de um modelo existente")
    end
  end

  context "Métodos da Classe" do
    describe "#em_uso?" do
      it "retorna false se não tem avaliações" do
        expect(modelo_existente.em_uso?).to be false
      end

      it "retorna true se tem avaliações associadas" do
        turma = Turma.create!(codigo: "T1", nome: "Turma Teste", semestre: "2024.1")
        # Cria uma avaliação fake associada
        Avaliacao.create!(modelo: modelo_existente, turma: turma)
        
        expect(modelo_existente.em_uso?).to be true
      end
    end

    describe "#clonar_com_perguntas" do
      it "cria uma cópia completa do modelo e suas perguntas" do
        original = modelo_existente
        novo_modelo = original.clonar_com_perguntas("Cópia do Modelo")

        # Verifica dados do novo modelo
        expect(novo_modelo).to be_persisted
        expect(novo_modelo.titulo).to eq("Cópia do Modelo")
        expect(novo_modelo.ativo).to be false # Deve nascer inativo
        expect(novo_modelo.id).not_to eq(original.id)

        # Verifica clonagem das perguntas
        expect(novo_modelo.perguntas.count).to eq(1)
        expect(novo_modelo.perguntas.first.enunciado).to eq(original.perguntas.first.enunciado)
        expect(novo_modelo.perguntas.first.id).not_to eq(original.perguntas.first.id)
      end
    end
  end

  context "Associações e Dependências" do
    it "destroy apaga as perguntas filhas" do
      modelo = modelo_existente
      expect { modelo.destroy }.to change(Pergunta, :count).by(-1)
    end

    it "não pode ser apagado se tiver avaliações (restrict_with_error)" do
      turma = Turma.create!(codigo: "T2", nome: "Turma Restrict", semestre: "2024.1")
      Avaliacao.create!(modelo: modelo_existente, turma: turma)

      expect { modelo_existente.destroy }.not_to change(Modelo, :count)
      expect(modelo_existente.errors[:base]).to be_present
    end
  end
end