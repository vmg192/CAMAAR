class Modelo < ApplicationRecord
  # Relacionamentos
  has_many :perguntas, dependent: :destroy
  has_many :avaliacoes, dependent: :restrict_with_error
  
  # Validações
  validates :titulo, presence: true, uniqueness: { case_sensitive: false }
  
  # Validação customizada: não permitir modelo sem perguntas
  validate :deve_ter_pelo_menos_uma_pergunta, on: :create
  validate :nao_pode_remover_todas_perguntas, on: :update
  
  # Aceita atributos aninhados para perguntas
  accepts_nested_attributes_for :perguntas, 
    allow_destroy: true, 
    reject_if: :all_blank
  
  # Método para verificar se modelo está em uso
  def em_uso?
    avaliacoes.any?
  end
  
  # Método para clonar modelo com perguntas
  def clonar_com_perguntas(novo_titulo)
    novo_modelo = dup
    novo_modelo.titulo = novo_titulo
    novo_modelo.ativo = false # Clones começam inativos
    novo_modelo.save
    
    if novo_modelo.persisted?
      perguntas.each do |pergunta|
        nova_pergunta = pergunta.dup
        nova_pergunta.modelo = novo_modelo
        nova_pergunta.save
      end
    end
    
    novo_modelo
  end
  
  private
  
  def deve_ter_pelo_menos_uma_pergunta
    if perguntas.empty? || perguntas.all? { |p| p.marked_for_destruction? }
      errors.add(:base, "Um modelo deve ter pelo menos uma pergunta")
    end
  end
  
  def nao_pode_remover_todas_perguntas
    if persisted? && (perguntas.empty? || perguntas.all? { |p| p.marked_for_destruction? })
      errors.add(:base, "Não é possível remover todas as perguntas de um modelo existente")
    end
  end
end
