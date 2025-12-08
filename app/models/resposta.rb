# app/models/resposta.rb
class Resposta < ApplicationRecord
  belongs_to :aluno, class_name: "User"
  belongs_to :formulario
  belongs_to :questao
  belongs_to :avaliacao, optional: true

  validates :aluno_id, presence: true
  validates :formulario_id, presence: true
  validates :questao_id, presence: true
  validates :conteudo, presence: true

  # Validação para garantir que um aluno não responda o mesmo formulário duas vezes
  validates_uniqueness_of :aluno_id, scope: [ :formulario_id, :questao_id ],
    message: "já respondeu esta questão neste formulário"
end
