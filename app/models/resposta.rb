class Resposta < ApplicationRecord
  self.table_name = "respostas"  # Plural correto em português

  belongs_to :submissao
  belongs_to :pergunta, foreign_key: "questao_id"  # Coluna ainda é questao_id no banco

  validates :conteudo, presence: true

  # Alias para compatibilidade
  alias_attribute :pergunta_id, :questao_id
end
