# app/models/questao.rb
class Questao < ApplicationRecord
  # Relacionamentos
  belongs_to :template
  has_many :respostas, dependent: :destroy
  
  # Tipos de questões disponíveis
  TIPOS = {
    'texto_longo' => 'Texto Longo',
    'texto_curto' => 'Texto Curto',
    'multipla_escolha' => 'Múltipla Escolha',
    'checkbox' => 'Checkbox (Múltipla Seleção)',
    'escala' => 'Escala Likert (1-5)',
    'data' => 'Data',
    'hora' => 'Hora'
  }.freeze
  
  # Validações
  validates :enunciado, presence: true
  validates :tipo, presence: true, inclusion: { in: TIPOS.keys }
  validates :ordem, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
  # Validações condicionais
  validate :opcoes_requeridas_para_multipla_escolha
  validate :opcoes_requeridas_para_checkbox
  
  # Callbacks
  before_validation :definir_ordem_padrao, on: :create
  after_save :reordenar_questoes
  
  # Métodos
  def tipo_humanizado
    TIPOS[tipo] || tipo
  end
  
  def requer_opcoes?
    ['multipla_escolha', 'checkbox'].include?(tipo)
  end
  
  def lista_opcoes
    return [] unless opcoes.present?
    opcoes.split(';').map(&:strip)
  end
  
  private
  
  def definir_ordem_padrao
    if ordem.nil? && template.present?
      ultima_ordem = template.questaos.maximum(:ordem) || 0
      self.ordem = ultima_ordem + 1
    end
  end
  
  def reordenar_questoes
    if ordem_changed? && template.present?
      template.questaos.where.not(id: id).order(:ordem, :created_at).each_with_index do |questao, index|
        questao.update_column(:ordem, index + 1) if questao.ordem != index + 1
      end
    end
  end
  
  def opcoes_requeridas_para_multipla_escolha
    if tipo == 'multipla_escolha' && (opcoes.blank? || opcoes.split(';').size < 2)
      errors.add(:opcoes, 'deve ter pelo menos duas opções para múltipla escolha')
    end
  end
  
  def opcoes_requeridas_para_checkbox
    if tipo == 'checkbox' && (opcoes.blank? || opcoes.split(';').size < 2)
      errors.add(:opcoes, 'deve ter pelo menos duas opções para checkbox')
    end
  end
end