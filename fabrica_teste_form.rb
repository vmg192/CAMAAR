# spec/factories/formularios.rb
FactoryBot.define do
  factory :formulario do
    titulo { 'Formulário de Avaliação' }
    data_limite { 1.week.from_now }
    association :template
    association :turma
  end
end