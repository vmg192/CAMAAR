require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:matricula_turmas) }
    it { should have_many(:turmas).through(:matricula_turmas) }
  end

  describe 'validations' do
    # Adicione validações aqui se houver
  end
end
