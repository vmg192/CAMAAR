require 'rails_helper'

RSpec.describe Avaliacao, type: :model do
  describe 'associações' do
    it 'pertence a turma' do
      expect(described_class.reflect_on_association(:turma).macro).to eq :belongs_to
    end

    it 'pertence a modelo' do
      expect(described_class.reflect_on_association(:modelo).macro).to eq :belongs_to
    end

    it 'pertence a professor_alvo como Usuario (opcional)' do
      assoc = described_class.reflect_on_association(:professor_alvo)
      expect(assoc.macro).to eq :belongs_to
      expect(assoc.class_name).to eq 'User'
      expect(assoc.options[:optional]).to eq true
    end
  end
end
