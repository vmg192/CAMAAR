require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'definicao_senha' do
    let(:user) { User.create(nome: 'Teste', email: 'teste@example.com', matricula: '111', password: 'password') }
    let(:mail) { UserMailer.definicao_senha(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Definição de Senha - Sistema de Gestão')
      expect(mail.to).to eq([user.email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Definição de Senha')
    end
  end

  describe 'cadastro_email' do
    let(:user) { User.create(nome: 'Teste', email: 'teste@example.com', matricula: '222', password: 'password') }
    let(:password) { 'secret123' }
    let(:mail) { UserMailer.cadastro_email(user, password) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Bem-vindo ao Sistema de Gestão - Cadastro Realizado')
      expect(mail.to).to eq([user.email])
    end

    it 'renders the body with password' do
      expect(mail.body.encoded).to match(password)
    end
  end
end
