class Avaliacao < ApplicationRecord
  belongs_to :turma
  belongs_to :modelo
  belongs_to :professor_alvo, class_name: 'Usuario', optional: true
end
