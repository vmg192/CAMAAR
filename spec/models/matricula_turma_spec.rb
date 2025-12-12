require 'rails_helper'

RSpec.describe MatriculaTurma, type: :model do
  describe 'associations' do
    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it 'belongs to turma' do
      association = described_class.reflect_on_association(:turma)
      expect(association.macro).to eq :belongs_to
    end
  end
end
