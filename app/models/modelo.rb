class Modelo < ApplicationRecord
  has_many :perguntas

  validates :titulo, presence: true
end
