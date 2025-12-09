# app/models/template.rb
class Template < ApplicationRecord
  # Relacionamentos
  has_many :questaos, dependent: :destroy
  has_many :formularios, dependent: :restrict_with_error
  
  # Validações
  validates :nome, presence: true, uniqueness: { case_sensitive: false }
  validates :descricao, presence: true
  
  # Validação customizada: não permitir template sem questões
  validate :deve_ter_pelo_menos_uma_questao, on: :create
  validate :nao_pode_remover_todas_questoes, on: :update
  
  # Aceita atributos aninhados para questões
  accepts_nested_attributes_for :questaos, 
    allow_destroy: true, 
    reject_if: :all_blank
  
  # Método para verificar se template está em uso
  def em_uso?
    formularios.any?
  end
  
  # Método para clonar template com questões
  def clonar_com_questoes(novo_nome)
    novo_template = dup
    novo_template.nome = novo_nome
    novo_template.save
    
    if novo_template.persisted?
      questaos.each do |questao|
        nova_questao = questao.dup
        nova_questao.template = novo_template
        nova_questao.save
      end
    end
    
    novo_template
  end
  
  private
  
  def deve_ter_pelo_menos_uma_questao
    if questaos.empty? || questaos.all? { |q| q.marked_for_destruction? }
      errors.add(:base, "Um template deve ter pelo menos uma questão")
    end
  end
  
  def nao_pode_remover_todas_questoes
    if persisted? && (questaos.empty? || questaos.all? { |q| q.marked_for_destruction? })
      errors.add(:base, "Não é possível remover todas as questões de um template existente")
    end
  end
end