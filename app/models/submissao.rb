class Submissao < ApplicationRecord
  self.table_name = 'submissoes'  # Plural correto em português
  
  belongs_to :aluno, class_name: 'User'
  belongs_to :avaliacao
  has_many :respostas, dependent: :destroy

  accepts_nested_attributes_for :respostas
end
