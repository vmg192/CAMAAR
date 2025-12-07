class Usuario < ApplicationRecord
  #mais codigo acima assumindo que Usuario ja exista
  has_many :matricula_turmas
  has_many :turmas, through: :matricula_turmas
end
