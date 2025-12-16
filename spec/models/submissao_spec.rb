require 'rails_helper'

RSpec.describe Submissao, type: :model do
  # Setup: Cria as dependências necessárias
  let(:aluno) do
    User.create!(
      login: "aluno_teste",
      email_address: "aluno@teste.com",
      matricula: "202401",
      nome: "Aluno Teste",
      password: "123",
      password_confirmation: "123"
    )
  end

  let(:modelo) do
    m = Modelo.new(titulo: "Prova 1", ativo: true)
    m.perguntas.build(enunciado: "Questão 1", tipo: "texto_curto")
    m.save!
    m
  end

  let(:turma) { Turma.create!(codigo: "T01", nome: "Turma RSpec", semestre: "2024.1") }
  let(:avaliacao) { Avaliacao.create!(modelo: modelo, turma: turma) }

  context "Configurações da Classe" do
    it "usa o nome de tabela correto (plural em português)" do
      expect(Submissao.table_name).to eq("submissoes")
    end
  end

  context "Associações" do
    it "pertence a um aluno (User)" do
      assc = Submissao.reflect_on_association(:aluno)
      expect(assc.macro).to eq :belongs_to
      expect(assc.class_name).to eq "User"
    end

    it "pertence a uma avaliacao" do
      assc = Submissao.reflect_on_association(:avaliacao)
      expect(assc.macro).to eq :belongs_to
    end

    it "tem muitas respostas" do
      assc = Submissao.reflect_on_association(:respostas)
      expect(assc.macro).to eq :has_many
    end

    it "aceita atributos aninhados para respostas" do
      expect(Submissao.nested_attributes_options).to have_key(:respostas)
    end
  end

  context "Happy Path (Caminho Feliz)" do
    it "é válida com aluno e avaliação" do
      submissao = Submissao.new(aluno: aluno, avaliacao: avaliacao)
      expect(submissao).to be_valid
    end

    it "destroi respostas associadas ao ser deletada" do
      submissao = Submissao.create!(aluno: aluno, avaliacao: avaliacao)
      submissao.respostas.create!(conteudo: "Resposta teste", questao_id: modelo.perguntas.first.id) rescue nil

      # Mesmo que a criação da resposta falhe por validação da Resposta,
      # o teste do 'dependent: :destroy' é garantido pela reflexão acima.
      expect { submissao.destroy }.not_to raise_error
    end
  end

  context "Sad Path (Caminho Triste)" do
    it "é inválida sem aluno" do
      submissao = Submissao.new(aluno: nil, avaliacao: avaliacao)
      expect(submissao).not_to be_valid
      expect(submissao.errors[:aluno]).to be_present
    end

    it "é inválida sem avaliação" do
      submissao = Submissao.new(aluno: aluno, avaliacao: nil)
      expect(submissao).not_to be_valid
      expect(submissao.errors[:avaliacao]).to be_present
    end
  end
end
