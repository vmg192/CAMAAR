# Representa a resposta de um aluno a uma pergunta
class Resposta < ApplicationRecord
  self.table_name = "respostas"

  belongs_to :submissao
  belongs_to :pergunta, foreign_key: "questao_id"

  validates :conteudo, presence: true

  alias_attribute :pergunta_id, :questao_id
end
