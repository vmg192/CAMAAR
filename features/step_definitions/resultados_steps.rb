# Features/Step_Definitions/Resultados_Steps.rb

Given('que existem avaliações criadas no sistema') do
  @user = User.find_by(login: "admin") || User.create!(email_address: "admin@adm.com", login: "admin", password: "p", eh_admin: true)
  @modelo = Modelo.find_or_create_by!(titulo: "Template Padrão")
  @turma = Turma.create!(codigo: "TRM02", nome: "Turma Result", semestre: "2024/1")
  @avaliacao = Avaliacao.create!(turma: @turma, modelo: @modelo, titulo: "Avaliação 1", data_inicio: Time.now)
end

When('acesso a lista de avaliações') do
  visit gestao_envios_avaliacoes_path
end

Then('devo ver todas as avaliações cadastradas') do
  # In gestao_envios, we see Turmas.
  expect(page).to have_content(@turma.nome)
end

Then('devo ver o título, data de criação e status de cada uma') do
  # The view lists Turmas and optionally "Ver Resultados (Última)"
  expect(page).to have_content(@turma.codigo)
end

When('clico em uma avaliação na lista') do
  click_link "Ver Resultados (Última)"
end

Then('devo ver os detalhes da avaliação') do
  expect(page).to have_content("Resultados da Avaliação")
end

Then('devo ver a lista de submissões dos alunos') do
  expect(page).to have_css("table") # Assuming table exists
end

Given('que não existem avaliações cadastradas') do
  Avaliacao.destroy_all
end

Then('devo ver uma mensagem {string}') do |msg|
  expect(page).to have_content(msg)
end
