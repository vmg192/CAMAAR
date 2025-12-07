# spec/models/formulario_spec.rb
require 'rails_helper'

RSpec.describe Formulario, type: :model do
  describe '#disponivel_para_resposta?' do
    it 'retorna true quando a data limite é futura' do
      formulario = build(:formulario, data_limite: 1.day.from_now)
      expect(formulario.disponivel_para_resposta?).to be true
    end
    
    it 'retorna false quando a data limite é passada' do
      formulario = build(:formulario, data_limite: 1.day.ago)
      expect(formulario.disponivel_para_resposta?).to be false
    end
  end
  
  describe '#aluno_respondeu_tudo?' do
    let(:formulario) { create(:formulario) }
    let(:aluno) { create(:user) }
    let(:questoes) { create_list(:questao, 3, template: formulario.template) }
    
    it 'retorna false quando o aluno não respondeu todas as questões' do
      # Cria respostas para apenas 2 das 3 questões
      create(:resposta, formulario: formulario, aluno: aluno, questao: questoes[0])
      create(:resposta, formulario: formulario, aluno: aluno, questao: questoes[1])
      
      expect(formulario.aluno_respondeu_tudo?(aluno.id)).to be false
    end
    
    it 'retorna true quando o aluno respondeu todas as questões' do
      # Cria respostas para todas as questões
      questoes.each do |questao|
        create(:resposta, formulario: formulario, aluno: aluno, questao: questao)
      end
      
      expect(formulario.aluno_respondeu_tudo?(aluno.id)).to be true
    end
  end
end