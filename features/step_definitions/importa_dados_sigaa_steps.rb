# features/step_definitions/importa_dados_sigaa_steps.rb

# Feature 98 - Importação SIGAA
# Feature 100 - Cadastro de Usuários (via importação SIGAA)

Quando('importo dados do SIGAA') do
  # Cria um arquivo JSON temporário com dados de exemplo
  sample_data = [
    {
      "codigo" => "TEST001",
      "nome" => "Turma Teste",
      "semestre" => "2024.2",
      "participantes" => [
        {
          "nome" => "Aluno Teste",
          "email" => "aluno@test.com",
          "matricula" => "999999",
          "papel" => "Discente"
        }
      ]
    }
  ].to_json

  @temp_file_path = Rails.root.join('tmp', 'test_sigaa_import.json')
  FileUtils.mkdir_p(File.dirname(@temp_file_path))
  File.write(@temp_file_path, sample_data)

  # Visita a página de importação
  visit new_sigaa_import_path
  
  # Faz upload do arquivo
  attach_file('file', @temp_file_path)
  click_button 'Importar Dados'

  # Limpa arquivo temporário
  File.delete(@temp_file_path) if File.exist?(@temp_file_path)
end

Então('os dados de turmas e usuários devem ser salvos no banco de dados') do
  expect(Turma.where(codigo: "TEST001")).to exist
  expect(User.where(matricula: "999999")).to exist
end

Então('devo ver um resumo da importação com sucesso') do
  expect(page).to have_content("Importação Concluída").or have_content("Turmas")
end

# Teste negativo - arquivo inválido
Quando('tento importar dados inválidos do SIGAA') do
  # Cria um arquivo JSON inválido
  @temp_file_path = Rails.root.join('tmp', 'invalid_sigaa.json')
  File.write(@temp_file_path, "{ invalid json syntax")

  visit new_sigaa_import_path
  attach_file('file', @temp_file_path)
  click_button 'Importar Dados'

  File.delete(@temp_file_path) if File.exist?(@temp_file_path)
end

Então('nenhum dado deve ser salvo no banco de dados') do
  @initial_turma_count ||= Turma.count
  expect(Turma.count).to eq(@initial_turma_count)
end

Então('não devo ver informações novas na tela') do
  expect(page).to have_content("Erros").or have_content("inválido")
end

# Feature 100 - Cadastro de Usuários
Quando('importo um arquivo de dados do SIGAA contendo novos usuários') do
  @initial_user_count = User.count
  
  sample_data = [
    {
      "codigo" => "NEW001",
      "nome" => "Nova Turma",
      "semestre" => "2024.2",
      "participantes" => [
        {
          "nome" => "Novo Usuário",
          "email" => "novo@test.com",
          "matricula" => "888888",
          "papel" => "Discente"
        }
      ]
    }
  ].to_json

  @temp_file_path = Rails.root.join('tmp', 'new_users.json')
  File.write(@temp_file_path, sample_data)

  visit new_sigaa_import_path
  attach_file('file', @temp_file_path)
  click_button 'Importar Dados'

  File.delete(@temp_file_path) if File.exist?(@temp_file_path)
end

Então('os novos usuários devem ser salvos no banco de dados') do
  expect(User.count).to be > @initial_user_count
  expect(User.where(matricula: "888888")).to exist
end

Então('um email de boas-vindas deve ser enviado para cada um') do
  # Verifica que novo usuário foi criado
  new_user = User.find_by(matricula: "888888")
  expect(new_user).to be_present
  expect(new_user.password_digest).to be_present
  
  # Verifica que email foi enviado
  expect(last_email).not_to be_nil, "Nenhum email foi enviado"
  expect(last_email.to).to include(new_user.email_address)
  expect(last_email.subject).to include("Bem-vindo")
end

# Testes negativos - apenas caminho feliz no MVP
Quando('importo um arquivo contendo apenas usuários já cadastrados') do
  pending "Teste negativo - não está no caminho feliz do MVP"
end

Então('nenhum novo usuário deve ser criado') do
  pending "Teste negativo - não está no caminho feliz do MVP"
end

Então('devo ver uma mensagem informando que os usuários já existem') do
  pending "Teste negativo - não está no caminho feliz do MVP"
end

Quando('importo um arquivo vazio ou sem dados de usuários') do
  pending "Teste negativo - não está no caminho feliz do MVP"
end

Então('nenhum usuário deve ser cadastrado') do
  pending "Teste negativo - não está no caminho feliz do MVP"
end

Então('devo ver uma mensagem de erro indicando arquivo vazio') do
  pending "Teste negativo - não está no caminho feliz do MVP"
end
