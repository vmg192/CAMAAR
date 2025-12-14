# Classe que representa um usuário do sistema.
# Responsável pela autenticação, dados cadastrais e relação com turmas e submissões.
class User < ApplicationRecord
  # Adiciona métodos para definir e autenticar senhas usando BCrypt.
  #
  # Descrição: Gera o atributo 'password_digest' e os atributos virtuais 'password' e 'password_confirmation'.
  # Efeitos Colaterais: Criptografa a senha antes de salvar no banco.
  has_secure_password

  # Relacionamentos
  has_many :sessions, dependent: :destroy
  has_many :matricula_turmas
  has_many :turmas, through: :matricula_turmas
  # Associação com submissões onde o usuário atua como aluno
  has_many :submissoes, class_name: "Submissao", foreign_key: :aluno_id, dependent: :destroy

  # Validações de integridade dos dados
  validates :email_address, presence: true, uniqueness: true
  validates :login, presence: true, uniqueness: true
  validates :matricula, presence: true, uniqueness: true
  validates :nome, presence: true

  # Normalização de atributos
  #
  # Descrição: Transforma o email e o login para letras minúsculas e remove espaços
  # no início e fim antes de salvar ou consultar.
  # Argumentos: Recebe o valor bruto do atributo (e/l).
  # Retorno: String normalizada.
  # Efeitos Colaterais: Altera o valor do atributo antes da validação.
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :login, with: ->(l) { l.strip.downcase }
end
