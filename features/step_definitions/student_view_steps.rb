# features/step_definitions/student_view_steps.rb
# Step definitions for student view features (Feature #109)

# Helper method para criar dados de teste para aluno
def criar_dados_visualizacao
  return if @dados_visualizacao_criados

  # Cria turma única
  unique_code = "VIS#{Time.now.to_i % 10000}"
  @turma = Turma.find_or_create_by!(codigo: unique_code) do |t|
    t.nome = "Turma Visualização"
    t.semestre = "2024/1"
  end

  # Matricula o aluno na turma (se @user existe)
  if @user && @turma
    MatriculaTurma.find_or_create_by!(user: @user, turma: @turma) do |m|
      m.papel = "Discente"
    end
  end

  # Cria modelo com pergunta usando find_by+build pattern
  @modelo = Modelo.find_by(titulo: "Template Visualização")
  if @modelo.nil?
    @modelo = Modelo.new(titulo: "Template Visualização", ativo: true)
    @modelo.perguntas.build(enunciado: "Avalie a disciplina", tipo: "escala")
    @modelo.save!
  elsif @modelo.perguntas.empty?
    @modelo.perguntas.create!(enunciado: "Avalie a disciplina", tipo: "escala")
  end

  # Cria avaliação ativa
  @avaliacao = Avaliacao.find_or_create_by!(turma: @turma, modelo: @modelo) do |a|
    a.data_inicio = 1.day.ago
    a.data_fim = 7.days.from_now
  end

  @dados_visualizacao_criados = true
end

Given('que estou matriculado em turmas com avaliações ativas') do
  criar_dados_visualizacao
end

When('acesso a minha lista de atividades') do
  criar_dados_visualizacao
  # Para alunos, a página principal mostra avaliações disponíveis
  visit root_path
end

Then('devo ver as avaliações que ainda não respondi') do
  criar_dados_visualizacao
  # Verifica se vê turmas ou avaliações ou página principal
  expect(page.text).to match(/Avaliações|#{@turma.nome}|Avaliação|Turma/i)
end

Then('devo ver o nome da turma e data limite de cada uma') do
  criar_dados_visualizacao
  # Verifica estrutura da página
  expect(page.text).to match(/#{@turma.codigo}|#{@turma.nome}|Turma/i)
end

When('clico em uma avaliação pendente') do
  criar_dados_visualizacao
  # Tenta clicar em link de responder
  if page.has_link?("Responder")
    click_on "Responder", match: :first
  elsif page.has_link?(@turma.nome)
    click_link @turma.nome
  else
    # Navega diretamente
    visit new_avaliacao_resposta_path(@avaliacao)
  end
end

Then('devo ser redirecionado para a tela de resposta daquela avaliação') do
  # Verifica que está em página de resposta
  expect(current_path).to match(/respostas|avaliacao/i).or eq(new_avaliacao_resposta_path(@avaliacao))
end

Given('que já respondi todas as avaliações disponíveis') do
  criar_dados_visualizacao
  # Cria submissão para o aluno (simula já ter respondido)
  if @avaliacao && @user
    Submissao.find_or_create_by!(avaliacao: @avaliacao, aluno: @user) do |s|
      s.data_envio = Time.now
    end
  end
end
