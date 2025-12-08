# app/models/formulario.rb
class Formulario < ApplicationRecord
  belongs_to :template
  belongs_to :turma
  has_many :respostas, dependent: :destroy
  has_many :questoes, through: :template

  validates :titulo, presence: true
  validates :data_limite, presence: true
  validates :template_id, presence: true
  validates :turma_id, presence: true

  # Método para verificar se o formulário está disponível para resposta
  def disponivel_para_resposta?
    data_limite > Time.current
  end

  # Método para verificar se um aluno já respondeu todas as questões
  def aluno_respondeu_tudo?(aluno_id)
    questoes_respondidas = respostas.where(aluno_id: aluno_id).pluck(:questao_id)
    questoes_ids = questoes.pluck(:id)
    (questoes_ids - questoes_respondidas).empty?
  end
end
