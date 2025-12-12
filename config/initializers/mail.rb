# config/initializers/mail.rb
# Configuração de email para CAMAAR

if Rails.env.test?
  # Em testes: captura emails sem enviar
  Rails.application.config.action_mailer.delivery_method = :test
  Rails.application.config.action_mailer.default_url_options = {
    host: "localhost",
    port: 3000
  }

elsif Rails.env.development?
  # MVP: Usa letter_opener (emails abrem no navegador)
  # Instale: gem install letter_opener ou adicione ao Gemfile
  # PRODUÇÃO: Para enviar emails reais, descomente a seção SMTP abaixo

  Rails.application.config.action_mailer.delivery_method = :letter_opener
  Rails.application.config.action_mailer.perform_deliveries = true

  # === SMTP (Para Produção) ===
  # Descomente as linhas abaixo e configure variáveis de ambiente (.env)
  # para enviar emails reais via SMTP (Gmail, Sendgrid, etc.)
  #
  # Rails.application.config.action_mailer.delivery_method = :smtp
  # Rails.application.config.action_mailer.raise_delivery_errors = true
  #
  # Rails.application.config.action_mailer.smtp_settings = {
  #   address: ENV.fetch('SMTP_ADDRESS', 'smtp.gmail.com'),
  #   port: ENV.fetch('SMTP_PORT', '587').to_i,
  #   domain: ENV.fetch('SMTP_DOMAIN', 'localhost'),
  #   user_name: ENV['SMTP_USER'],
  #   password: ENV['SMTP_PASSWORD'],
  #   authentication: 'plain',
  #   enable_starttls_auto: true
  # }

  Rails.application.config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST", "localhost"),
    port: ENV.fetch("APP_PORT", "3000").to_i
  }

else
  # Produção: SMTP obrigatório
  Rails.application.config.action_mailer.delivery_method = :smtp
  Rails.application.config.action_mailer.perform_deliveries = true
  Rails.application.config.action_mailer.raise_delivery_errors = false

  Rails.application.config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS"),
    port: ENV.fetch("SMTP_PORT", "587").to_i,
    domain: ENV.fetch("SMTP_DOMAIN"),
    user_name: ENV.fetch("SMTP_USER"),
    password: ENV.fetch("SMTP_PASSWORD"),
    authentication: "plain",
    enable_starttls_auto: true,
    open_timeout: 10,
    read_timeout: 10
  }

  Rails.application.config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST"),
    protocol: "https"
  }
end
