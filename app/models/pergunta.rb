# Classe que representa uma pergunta associada a um modelo de questionário.
class Pergunta < ApplicationRecord
  self.table_name = "perguntas"

  # Relacionamentos
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

  # Validações
  validates :enunciado, presence: true
  validates :tipo, presence: true, inclusion: { in: TIPOS.keys }

  # Validações condicionais
  validate :validar_minimo_opcoes, if: :requer_opcoes?

  # Retorna o nome legível do tipo da pergunta.
  #
  # Descrição: Converte a chave do tipo (ex: 'texto_curto') para o valor legível (ex: 'Texto Curto').
  # Argumentos: Nenhum.
  # Retorno: String (O nome formatado do tipo).
  # Efeitos Colaterais: Nenhum.
  def tipo_humanizado
    TIPOS[tipo] || tipo
  end

  # Verifica se o tipo de pergunta exige opções de resposta.
  #
  # Descrição: Checa se a pergunta é do tipo múltipla escolha ou checkbox.
  # Argumentos: Nenhum.
  # Retorno: Boolean.
  # Efeitos Colaterais: Nenhum.
  def requer_opcoes?
    %w[multipla_escolha checkbox].include?(tipo)
  end

  # Processa e retorna as opções da pergunta.
  #
  # Descrição: Normaliza o campo 'opcoes', lidando com Array, String JSON ou String separada por ponto e vírgula.
  # Argumentos: Nenhum.
  # Retorno: Array (Lista de strings com as opções).
  # Efeitos Colaterais: Pode realizar parse de JSON.
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

  # Auxiliar para converter string de opções em array.
  #
  # Descrição: Tenta parsear JSON, se falhar, usa split por ';'.
  # Argumentos: Nenhum (usa atributo interno).
  # Retorno: Array de strings.
  # Efeitos Colaterais: Nenhum.
  def parse_opcoes_string
    JSON.parse(opcoes)
  rescue JSON::ParserError
    opcoes.split(";").map(&:strip)
  end

  # Validação de quantidade mínima de opções.
  #
  # Descrição: Garante que perguntas de múltipla escolha tenham ao menos 2 alternativas.
  # Argumentos: Nenhum.
  # Retorno: Adiciona erro ao objeto se falhar.
  # Efeitos Colaterais: Nenhum.
  def validar_minimo_opcoes
    opcoes_lista = lista_opcoes

    if opcoes_lista.blank? || opcoes_lista.size < 2
      nome_tipo = tipo == "multipla_escolha" ? "múltipla escolha" : "checkbox"
      errors.add(:opcoes, "deve ter pelo menos duas opções para #{nome_tipo}")
    end
  end
end
