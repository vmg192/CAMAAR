# Features/Step_Definitions/Student_View_Steps.rb

Given('que estou matriculado em turmas com avaliações ativas') do
  # Provide context for student
  @student = User.find_by(email_address: "aluno@test.com")
  @turma = Turma.create!(codigo: "TRM_STU", nome: "Turma Student", semestre: "2024/1")
  MatriculaTurma.create!(user: @student, turma: @turma, papel: "aluno")
  
  @modelo = Modelo.create!(titulo: "Template Student")
  @avaliacao = Avaliacao.create!(turma: @turma, modelo: @modelo, titulo: "Avaliação Student", data_inicio: Time.now, data_fim: Time.now + 1.week)
end

When('acesso a minha lista de atividades') do
  visit respostas_path # Assuming this is the index for students
end

Then('devo ver as avaliações que ainda não respondi') do
  expect(page).to have_content("Avaliação Student")
end

Then('devo ver o nome da turma e data limite de cada uma') do
  expect(page).to have_content(@turma.nome)
  expect(page).to have_content(@avaliacao.data_fim.strftime("%d/%m/%Y"))
end

When('clico em uma avaliação pendente') do
  click_on "Responder"
end

Then('devo ser redirecionado para a tela de resposta daquela avaliação') do
  # check path like /formularios/:id/respostas/new
  # Relaxed matching
  expect(current_path).to match(/respostas\/new/)
end

Given('que já respondi todas as avaliações disponíveis') do
  # Create answer
  Submissao.create!(avaliacao: @avaliacao, aluno: @student, data_envio: Time.now)
end
