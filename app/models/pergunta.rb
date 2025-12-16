# Representa uma pergunta de um modelo de avaliação
class Pergunta < ApplicationRecord
  self.table_name = "perguntas"

  belongs_to :modelo
  has_many :respostas, foreign_key: "questao_id", dependent: :destroy

  # Tipos de perguntas disponíveis
  TIPOS = {
    "texto_longo" => "Texto Longo",
    "texto_curto" => "Texto Curto",
    "multipla_escolha" => "Múltipla Escolha",
    "checkbox" => "Checkbox (Múltipla Seleção)",
    "escala" => "Escala Likert (1-5)",
    "data" => "Data",
    "hora" => "Hora"
  }.freeze

  validates :enunciado, presence: true
  validates :tipo, presence: true, inclusion: { in: TIPOS.keys }

  validate :opcoes_requeridas_para_multipla_escolha
  validate :opcoes_requeridas_para_checkbox

  before_validation :definir_ordem_padrao, on: :create

  # Retorna tipo legível
  # @return [String]
  def tipo_humanizado
    TIPOS[tipo] || tipo
  end

  # Verifica se tipo requer opções
  # @return [Boolean]
  def requer_opcoes?
    %w[multipla_escolha checkbox].include?(tipo)
  end

  # Retorna lista de opções
  # @return [Array<String>]
  def lista_opcoes
    return [] unless opcoes.present?
    if opcoes.is_a?(Array)
      opcoes
    elsif opcoes.is_a?(String)
      parse_opcoes_string
    else
      []
    end
  end

  private

  def definir_ordem_padrao
    if modelo.present?
      ultima_ordem = modelo.perguntas.maximum(:id) || 0
    end
  end

  def opcoes_requeridas_para_multipla_escolha
    return unless tipo == "multipla_escolha"

    opcoes_lista = lista_opcoes
    if opcoes_lista.blank? || opcoes_lista.size < 2
      errors.add(:opcoes, "deve ter pelo menos duas opções para múltipla escolha")
    end
  end

  def opcoes_requeridas_para_checkbox
    return unless tipo == "checkbox"

    opcoes_lista = lista_opcoes
    if opcoes_lista.blank? || opcoes_lista.size < 2
      errors.add(:opcoes, "deve ter pelo menos duas opções para checkbox")
    end
  end

  def parse_opcoes_string
    JSON.parse(opcoes)
  rescue JSON::ParserError
    opcoes.split(";").map(&:strip)
  end
end
