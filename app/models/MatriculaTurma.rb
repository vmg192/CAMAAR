class MatriculaTurma < ApplicationRecord
  belongs_to :usuario
  belongs_to :turma
end
