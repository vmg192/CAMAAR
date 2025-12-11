require 'rails_helper'

RSpec.describe MatriculaTurma, type: :model do
  describe 'associations' do
    it { should belong_to(:user).with_foreign_key('usuario_id') }
    it { should belong_to(:turma) }
  end
end
