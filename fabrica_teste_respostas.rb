# spec/factories/respostas.rb
FactoryBot.define do
  factory :resposta do
    conteudo { 'Resposta de exemplo' }
    association :aluno, factory: :user
    association :formulario
    association :questao
  end
end