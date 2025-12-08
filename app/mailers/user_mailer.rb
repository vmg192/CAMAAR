class UserMailer < ApplicationMailer
  def definicao_senha(user)
    @user = user
    @url  = "http://localhost:3000/definicao_senha" #ajustar conforme o necessario
    mail(to: @user.email, subject: 'Definição de Senha - Sistema de Gestão')
  end
end
