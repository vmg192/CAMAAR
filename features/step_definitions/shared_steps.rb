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
  is_admin = (perfil == 'administrador')
  suffix = is_admin ? "admin" : "aluno"
  
  @user = User.find_by(login: "auto_#{suffix}") || User.create!(
    email_address: "#{suffix}@test.com",
    password: "password",
    login: "auto_#{suffix}",
    matricula: is_admin ? "ADM01" : "000000000",
    eh_admin: is_admin,
    nome: "Auto #{suffix.capitalize}"
  )

  visit new_session_path
  fill_in "email_address", with: @user.email_address
  fill_in "password", with: "password"
  click_button "Entrar"
end

Given(/^(?:que )?um "([^"]*)" está logado$/) do |perfil|
  step "que estou logado como \"#{perfil}\""
end

Given(/^(?:que )?está na tela "([^"]*)"$/) do |tela|
  # Map descriptive screen names to paths
  path = case tela
         when "Relatórios", "Resultados do Formulário" then gestao_envios_avaliacoes_path 
         when "Gerenciamento" then gestao_envios_avaliacoes_path 
         when "Templates", "Gestão de Envios" then gestao_envios_avaliacoes_path
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
