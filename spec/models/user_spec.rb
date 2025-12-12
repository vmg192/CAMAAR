require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it 'has many matricula_turmas' do
      association = described_class.reflect_on_association(:matricula_turmas)
      expect(association.macro).to eq :has_many
    end

    it 'has many turmas through matricula_turmas' do
      association = described_class.reflect_on_association(:turmas)
      expect(association.macro).to eq :has_many
      expect(association.options[:through]).to eq :matricula_turmas
    end
  end

  describe 'validations' do
    # Adicione validações aqui se houver
  end
end
