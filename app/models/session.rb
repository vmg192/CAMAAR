# Representa uma sessão de login do usuário
class Session < ApplicationRecord
  belongs_to :user
end
