require 'rails_helper'

RSpec.describe Turma, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:codigo) }
    it { should validate_presence_of(:nome) }
    it { should validate_presence_of(:semestre) }
  end

  describe 'associations' do
    it { should have_many(:matricula_turmas) }
    it { should have_many(:usuarios).through(:matricula_turmas) }
  end
end
