class Avaliacao < ApplicationRecord
  belongs_to :turma
  belongs_to :modelo
  belongs_to :professor_alvo, class_name: "User", optional: true

  has_many :submissoes, class_name: "Submissao", dependent: :destroy
  has_many :respostas, through: :submissoes
end
