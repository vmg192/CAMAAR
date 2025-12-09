class MatriculaTurma < ApplicationRecord
  belongs_to :user
  belongs_to :turma
end
