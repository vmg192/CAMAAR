# features/step_definitions/email_steps.rb
# Steps para verificar envio de emails

Então('um email deve ter sido enviado para {string}') do |email_address|
  emails = emails_sent_to(email_address)
  expect(emails).not_to be_empty, "Nenhum email foi enviado para #{email_address}"
end

Então('um email de boas-vindas deve ser enviado para {string}') do |email_address|
  emails = emails_sent_to(email_address)
  expect(emails).not_to be_empty, "Nenhum email foi enviado para #{email_address}"

  email = emails.last
  expect(email.subject).to include('Bem-vindo')
end

Então('o email deve conter a senha temporária') do
  email = last_email
  expect(email).not_to be_nil, "Nenhum email foi enviado"

  # Verifica se o email contém uma senha (padrão hex de 16 caracteres)
  body = email.body.to_s
  expect(body).to match(/[a-f0-9]{16}/i), "Email não contém senha temporária"
end

Então('o email deve conter {string}') do |texto|
  email = last_email
  expect(email).not_to be_nil, "Nenhum email foi enviado"

  body = email.body.to_s
  expect(body).to include(texto), "Email não contém o texto esperado: #{texto}"
end

Então('o assunto do email deve ser {string}') do |assunto|
  email = last_email
  expect(email).not_to be_nil, "Nenhum email foi enviado"
  expect(email.subject).to eq(assunto)
end

Então('{int} email(s) deve(m) ter sido enviado(s)') do |count|
  expect(all_emails.count).to eq(count),
    "Esperava #{count} emails, mas #{all_emails.count} foram enviados"
end

Então('nenhum email deve ter sido enviado') do
  expect(all_emails).to be_empty,
    "Esperava nenhum email, mas #{all_emails.count} foram enviados"
end

# Step mais detalhado para debugging
Então('mostrar último email enviado') do
  email = last_email
  if email
    puts "\n========== ÚLTIMO EMAIL ENVIADO =========="
    puts "Para: #{email.to.join(', ')}"
    puts "Assunto: #{email.subject}"
    puts "Corpo:"
    puts email.body
    puts "=========================================="
  else
    puts "Nenhum email foi enviado ainda"
  end
end
