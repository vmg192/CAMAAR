class Usuario < ApplicationRecord
  has_secure_password

  validates :login, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :matricula, presence: true, uniqueness: true
end