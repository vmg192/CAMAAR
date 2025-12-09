require 'rails_helper'

RSpec.describe CsvFormatterService do
  describe '#generate' do
    let(:modelo) { double('Modelo', perguntas: [
      double('Pergunta', enunciado: 'Q1'),
      double('Pergunta', enunciado: 'Q2')
    ])}
    
    let(:avaliacao) { double('Avaliacao', id: 1, modelo: modelo) }
    
    let(:aluno1) { double('User', matricula: '123', nome: 'Alice') }
    let(:aluno2) { double('User', matricula: '456', nome: 'Bob') }

    # Respostas não tem mais aluno direto, mas através de submissão
    let(:resposta_a1_q1) { double('Resposta', conteudo: 'Ans 1A') }
    let(:resposta_a1_q2) { double('Resposta', conteudo: 'Ans 1B') }
    let(:resposta_a2_q1) { double('Resposta', conteudo: 'Ans 2A') }

    # Submissoes ligando aluno e respostas
    let(:submissao1) { double('Submissao', aluno: aluno1, respostas: [resposta_a1_q1, resposta_a1_q2]) }
    let(:submissao2) { double('Submissao', aluno: aluno2, respostas: [resposta_a2_q1]) }

    before do
      # Mock da cadeia: avaliacao.submissoes.includes.each
      # Simulando o comportamento do loop no service
      allow(avaliacao).to receive_message_chain(:submissoes, :includes).and_return([submissao1, submissao2])
    end

    it 'gera uma string CSV válida com cabeçalhos e linhas' do
      csv_string = described_class.new(avaliacao).generate
      rows = csv_string.split("\n")

      # Cabeçalhos: Matrícula, Nome, Questão 1, Questão 2
      expect(rows[0]).to include("Matrícula,Nome,Questão 1,Questão 2")
      
      # Linha 1: Respostas da Alice
      expect(rows[1]).to include("123,Alice,Ans 1A,Ans 1B")
      
      # Linha 2: Respostas do Bob
      expect(rows[2]).to include("456,Bob,Ans 2A")
    end
  end
end
