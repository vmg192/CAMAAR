class Pergunta < ApplicationRecord
  self.table_name = 'perguntas'  # Plural correto em português
  
  # Relacionamentos
  belongs_to :modelo
  has_many :respostas, foreign_key: 'questao_id', dependent: :destroy
  
  # Tipos de perguntas disponíveis
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
  
  # Validações condicionais
  validate :opcoes_requeridas_para_multipla_escolha
  validate :opcoes_requeridas_para_checkbox
  
  # Callbacks
  before_validation :definir_ordem_padrao, on: :create
  
  # Métodos
  def tipo_humanizado
    TIPOS[tipo] || tipo
  end
  
  def requer_opcoes?
    ['multipla_escolha', 'checkbox'].include?(tipo)
  end
  
  def lista_opcoes
    return [] unless opcoes.present?
    # Assume que opcoes é JSON array ou string separada por ;
    if opcoes.is_a?(Array)
      opcoes
    elsif opcoes.is_a?(String)
      begin
        JSON.parse(opcoes)
      rescue JSON::ParserError
        opcoes.split(';').map(&:strip)
      end
    else
      []
    end
  end
  
  private
  
  def definir_ordem_padrao
    if modelo.present?
      ultima_ordem = modelo.perguntas.maximum(:id) || 0
      # Ordem pode ser baseada no ID para simplificar
    end
  end
  
  def opcoes_requeridas_para_multipla_escolha
    if tipo == 'multipla_escolha'
      opcoes_lista = lista_opcoes
      if opcoes_lista.blank? || opcoes_lista.size < 2
        errors.add(:opcoes, 'deve ter pelo menos duas opções para múltipla escolha')
      end
    end
  end
  
  def opcoes_requeridas_para_checkbox
    if tipo == 'checkbox'
      opcoes_lista = lista_opcoes
      if opcoes_lista.blank? || opcoes_lista.size < 2
        errors.add(:opcoes, 'deve ter pelo menos duas opções para checkbox')
      end
    end
  end
end
