class Pergunta < ApplicationRecord
  belongs_to :modelo

  validates :enunciado, presence: true
  validates :tipo, presence: true
end
