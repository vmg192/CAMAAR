# Representa um template de formulário com perguntas
class Modelo < ApplicationRecord
  has_many :perguntas, dependent: :destroy
  has_many :avaliacoes, dependent: :restrict_with_error

  validates :titulo, presence: true, uniqueness: { case_sensitive: false }

  validate :deve_ter_pelo_menos_uma_pergunta, on: :create
  validate :nao_pode_remover_todas_perguntas, on: :update

  accepts_nested_attributes_for :perguntas,
    allow_destroy: true,
    reject_if: :all_blank

  # Verifica se modelo está em uso
  # @return [Boolean] true se há avaliações usando este modelo
  def em_uso?
    avaliacoes.any?
  end

  # Duplica modelo com todas as perguntas
  # @param novo_titulo [String] Título para o novo modelo
  # @return [Modelo] Novo modelo criado
  # @efeito_colateral Cria novo Modelo e Perguntas no banco
  def clonar_com_perguntas(novo_titulo)
    novo_modelo = dup
    novo_modelo.titulo = novo_titulo
    novo_modelo.ativo = false
    novo_modelo.save

    # Copia as perguntas para a memória antes de salvar para passar na validação
    perguntas.each do |pergunta|
      nova_pergunta = pergunta.dup
      novo_modelo.perguntas << nova_pergunta
    end

    novo_modelo.save
    novo_modelo
  end

  private

  # Valida que modelo tenha pelo menos uma pergunta
  def deve_ter_pelo_menos_uma_pergunta
    if perguntas.empty? || perguntas.all? { |p| p.marked_for_destruction? }
      errors.add(:base, "Um modelo deve ter pelo menos uma pergunta")
    end
  end

  # Valida que não remova todas as perguntas
  def nao_pode_remover_todas_perguntas
    if persisted? && (perguntas.empty? || perguntas.all? { |p| p.marked_for_destruction? })
      errors.add(:base, "Não é possível remover todas as perguntas de um modelo existente")
    end
  end
end
