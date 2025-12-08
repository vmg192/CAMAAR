class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :matricula_turmas
  has_many :turmas, through: :matricula_turmas

  validates :email_address, presence: true, uniqueness: true
  validates :login, presence: true, uniqueness: true
  validates :matricula, presence: true, uniqueness: true
  validates :nome, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :login, with: ->(l) { l.strip.downcase }
end
