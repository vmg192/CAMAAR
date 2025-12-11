require 'rails_helper'

RSpec.describe Turma, type: :model do
  describe 'associations' do
    it 'has many matricula_turmas' do
      association = described_class.reflect_on_association(:matricula_turmas)
      expect(association.macro).to eq :has_many
    end

    it 'has many users through matricula_turmas' do
      association = described_class.reflect_on_association(:users)
      expect(association.macro).to eq :has_many
      expect(association.options[:through]).to eq :matricula_turmas
    end
  end
end
