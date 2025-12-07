class Turma < ApplicationRecord
  validates :codigo, :nome, :semestre, presence: true

  has_many :matricula_turmas
  has_many :usuarios, through: :matricula_turmas
end
