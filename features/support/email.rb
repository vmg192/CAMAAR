# features/support/email.rb
# Configuração para capturar emails em testes

Before do
  # Limpa emails enviados antes de cada cenário
  ActionMailer::Base.deliveries.clear
end

# Helper para acessar emails enviados
module EmailHelpers
  def last_email
    ActionMailer::Base.deliveries.last
  end
  
  def all_emails
    ActionMailer::Base.deliveries
  end
  
  def reset_emails
    ActionMailer::Base.deliveries.clear
  end
  
  def emails_sent_to(email_address)
    ActionMailer::Base.deliveries.select { |email| email.to.include?(email_address) }
  end
end

World(EmailHelpers)
