class UserMailer < ApplicationMailer
  # Email para definição de senha (método existente)
  def definicao_senha(user)
    @user = user
    @url  = "http://localhost:3000/definicao_senha"
    mail(to: @user.email, subject: 'Definição de Senha - Sistema de Gestão')
  end
  
  # Email de cadastro com senha temporária (novo método)
  def cadastro_email(user, senha_temporaria)
    @user = user
    @senha = senha_temporaria
    @login_url = new_session_url
    
    mail(
      to: @user.email_address,
      subject: 'Bem-vindo(a) ao CAMAAR - Sua senha de acesso'
    )
  end
end
