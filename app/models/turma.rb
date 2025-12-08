class Turma < ApplicationRecord
  has_many :avaliacoes
  # has_many :matricula_turmas
  # has_many :usuarios, through: :matricula_turmas
end
