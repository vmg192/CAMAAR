# Features/Step_Definitions/Shared_Steps.rb

# --- NAVIGATION ---
Given(/^(?:que )?estou na pagina "([^"]*)"$/) do |pagina|
  path = case pagina
  when "login" then new_session_path
  when "avaliacoes" then gestao_envios_avaliacoes_path # Corrected
  else root_path
  end
  visit path
end

# --- LOGIN ---
Given(/^(?:que )?estou logado como "([^"]*)"$/) do |perfil|
  # Normaliza perfil
  perfil_normalizado = case perfil.downcase
  when 'administrador', 'admin' then 'admin'
  when 'participante', 'aluno', 'estudante' then 'aluno'
  else 'aluno'
  end

  is_admin = (perfil_normalizado == 'admin')

  # Usa find_or_create_by para evitar duplicatas
  @user = User.find_or_create_by!(login: "auto_#{perfil_normalizado}") do |u|
    u.email_address = "auto_#{perfil_normalizado}@test.com"
    u.password = "password"
    u.matricula = is_admin ? "ADM00001" : "ALU00001"
    u.eh_admin = is_admin
    u.nome = "Auto #{perfil_normalizado.capitalize}"
  end

  visit new_session_path
  fill_in "email_address", with: @user.email_address
  fill_in "password", with: "password"
  click_button "Entrar"
end

Given(/^(?:que )?um "([^"]*)" está logado$/) do |perfil|
  step "que estou logado como \"#{perfil}\""
end

Given(/^(?:que )?está na tela ['\"]([^'\"]*)['\"]$/) do |tela|
  # Map descriptive screen names to paths
  path = case tela
  when "Relatórios", "Resultados do Formulário" then gestao_envios_avaliacoes_path
  when "Gerenciamento" then gestao_envios_avaliacoes_path
  when "Templates", "Gestão de Envios" then gestao_envios_avaliacoes_path
  when "Principal", "Home" then root_path
  when "Avaliação da Turma" then root_path # Aluno vê avaliações na home
  else root_path
  end
  visit path
end

# --- INTERACTION ---
When('preencho o campo {string} com {string}') do |campo, valor|
  field = case campo
  when "Login" then "email_address"
  when "Senha" then "password"
  else campo
  end
  fill_in field, with: valor
end

When('clico em {string}') do |botao|
  click_on botao
end

# --- ASSERTIONS ---
Then('devo visualizar a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Then('devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Then('devo ser redirecionado para a pagina {string}') do |pagina|
  path = case pagina
  when "avaliacoes" then avaliacoes_path
  when "login" then new_session_path
  when "home", "inicial" then root_path
  else root_path
  end
  expect(current_path).to eq(path)
end

# --- ADDITIONAL STEPS ---
# Note: `está na tela` já definido acima com regex

# Database loaded step
Given("que o o banco de dados está {string}") do |estado|
  # O banco de dados já está configurado pelo test_data.rb
  # Este step é apenas para documentação
end

Given('o banco de dados está {string}') do |estado|
  # O banco de dados já está configurado pelo test_data.rb
  # Este step é apenas para documentação
end
