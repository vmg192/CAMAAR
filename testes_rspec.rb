# spec/models/resposta_spec.rb
require 'rails_helper'

RSpec.describe Resposta, type: :model do
  let(:aluno) { create(:user, tipo: 'aluno') }
  let(:formulario) { create(:formulario) }
  let(:questao) { create(:questao, template: formulario.template) }
  
  it 'é válido com atributos completos' do
    resposta = Resposta.new(
      aluno: aluno,
      formulario: formulario,
      questao: questao,
      conteudo: 'Resposta de teste'
    )
    expect(resposta).to be_valid
  end
  
  it 'não é válido sem conteúdo' do
    resposta = Resposta.new(
      aluno: aluno,
      formulario: formulario,
      questao: questao,
      conteudo: nil
    )
    expect(resposta).not_to be_valid
  end
  
  describe 'validação de unicidade' do
    let!(:resposta_existente) do
      create(:resposta, aluno: aluno, formulario: formulario, questao: questao)
    end
    
    it 'não permite que um aluno responda a mesma questão duas vezes' do
      resposta_duplicada = Resposta.new(
        aluno: aluno,
        formulario: formulario,
        questao: questao,
        conteudo: 'Outra resposta'
      )
      expect(resposta_duplicada).not_to be_valid
      expect(resposta_duplicada.errors[:aluno_id]).to include('já respondeu esta questão neste formulário')
    end
  end
end