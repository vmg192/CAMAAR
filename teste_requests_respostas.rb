# spec/requests/respostas_spec.rb
require 'rails_helper'

RSpec.describe 'Respostas', type: :request do
  let(:aluno) { create(:user, tipo: 'aluno') }
  let(:formulario) { create(:formulario, data_limite: 1.week.from_now) }
  let(:questoes) { create_list(:questao, 2, template: formulario.template) }
  
  before do
    sign_in aluno
  end
  
  describe 'GET /respostas' do
    it 'retorna sucesso' do
      get respostas_path
      expect(response).to have_http_status(:success)
    end
  end
  
  describe 'POST /formularios/:formulario_id/respostas' do
    context 'com parâmetros válidos' do
      it 'cria múltiplas respostas' do
        expect {
          post formulario_respostas_path(formulario), params: {
            formulario: {
              respostas: {
                questoes[0].id => 'Resposta 1',
                questoes[1].id => 'Resposta 2'
              }
            }
          }
        }.to change(Resposta, :count).by(2)
        
        expect(response).to redirect_to(respostas_path)
        expect(flash[:notice]).to eq('Formulário respondido com sucesso!')
      end
    end
    
    context 'com respostas em branco' do
      it 'não cria respostas e mostra alerta' do
        expect {
          post formulario_respostas_path(formulario), params: {
            formulario: {
              respostas: {
                questoes[0].id => '',
                questoes[1].id => 'Resposta 2'
              }
            }
          }
        }.not_to change(Resposta, :count)
        
        expect(flash[:alert]).to eq('Todas as questões são obrigatórias')
      end
    end
  end
end