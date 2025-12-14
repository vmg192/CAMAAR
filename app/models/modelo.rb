# Classe que representa um modelo de questionário.
# Serve como agregador de perguntas e definições da avaliação.
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

  # Verifica se o modelo já foi utilizado em alguma avaliação.
  #
  # Descrição: Checa se existem registros na tabela de avaliações associados a este modelo.
  # Argumentos: Nenhum.
  # Retorno: Boolean (true se estiver em uso, false caso contrário).
  # Efeitos Colaterais: Nenhum (apenas leitura).
  def em_uso?
    avaliacoes.any?
  end

  # Cria uma cópia profunda do modelo e suas perguntas.
  #
  # Descrição: Duplica o objeto Modelo e itera sobre suas perguntas para duplicá-las também,
  # associando-as ao novo modelo. O novo modelo nasce inativo.
  # Argumentos:
  #   - novo_titulo (String): O título que será atribuído ao novo modelo clonado.
  # Retorno: Objeto Modelo (a nova instância criada e salva).
  # Efeitos Colaterais:
  #   - Cria um novo registro na tabela 'modelos'.
  #   - Cria novos registros na tabela 'perguntas'.
  def clonar_com_perguntas(novo_titulo)
    novo_modelo = dup
    novo_modelo.titulo = novo_titulo
    novo_modelo.ativo = false # Clones começam inativos

    # Copia as perguntas para a memória antes de salvar para passar na validação
    perguntas.each do |pergunta|
      nova_pergunta = pergunta.dup
      novo_modelo.perguntas << nova_pergunta
    end

    novo_modelo.save
    novo_modelo
  end

  private

  # Valida se o modelo possui perguntas na criação.
  #
  # Descrição: Garante a regra de negócio de que um modelo não pode existir vazio.
  # Argumentos: Nenhum.
  # Retorno: Adiciona erro ao objeto se falhar.
  # Efeitos Colaterais: Nenhum.
  def deve_ter_pelo_menos_uma_pergunta
    if perguntas.empty? || perguntas.all? { |p| p.marked_for_destruction? }
      errors.add(:base, "Um modelo deve ter pelo menos uma pergunta")
    end
  end

  # Valida se o usuário está tentando remover todas as perguntas na edição.
  #
  # Descrição: Impede que um update deixe o modelo órfão de perguntas.
  # Argumentos: Nenhum.
  # Retorno: Adiciona erro ao objeto se falhar.
  # Efeitos Colaterais: Nenhum.
  def nao_pode_remover_todas_perguntas
    if persisted? && (perguntas.empty? || perguntas.all? { |p| p.marked_for_destruction? })
      errors.add(:base, "Não é possível remover todas as perguntas de um modelo existente")
    end
  end
end