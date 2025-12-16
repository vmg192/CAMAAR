# Representa a matrícula de um usuário em uma turma
class MatriculaTurma < ApplicationRecord
  belongs_to :user
  belongs_to :turma
end
