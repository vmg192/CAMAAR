# features/step_definitions/atualizar_base_dados_steps.rb

# Feature 108 - Atualizar Base de Dados com SIGAA

Quando('faço upload de um arquivo CSV do SIGAA com dados atualizados') do
  # Cria dados existentes primeiro
  @existing_turma = Turma.create!(
    codigo: "UPDATE001",
    nome: "Turma Antiga",
    semestre: "2024.1"
  )

  # Cria CSV com dados atualizados
  csv_data = "codigo_turma,nome_turma,semestre,nome_usuario,email,matricula,papel\n"
  csv_data += "UPDATE001,Turma Atualizada,2024.1,Usuario Atualizado,updated@test.com,777777,Discente\n"

  @temp_file_path = Rails.root.join('tmp', 'update_sigaa.csv')
  File.write(@temp_file_path, csv_data)
end

Quando('confirmo a operação') do
  visit new_sigaa_import_path
  attach_file('file', @temp_file_path)
  click_button 'Importar Dados'

  File.delete(@temp_file_path) if File.exist?(@temp_file_path)
end

Então('os registros existentes devem ser atualizados no banco de dados') do
  @existing_turma.reload
  expect(@existing_turma.nome).to eq("Turma Atualizada")
end

Then('devo ver um resumo das alterações realizadas') do
  expect(page).to have_content("concluída").or have_content("sucesso")
end

# Testes negativos - não estão no caminho feliz do MVP
Quando('faço upload de um arquivo inválido para atualização') do
  pending "Teste negativo - não está no caminho feliz do MVP"
end

Então('os dados não devem ser alterados') do
  pending "Teste negativo - não está no caminho feliz do MVP"
end

Então('devo ver uma mensagem de erro de formato') do
  pending "Teste negativo - não está no caminho feliz do MVP"
end
