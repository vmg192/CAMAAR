# features/step_definitions/responder_formulario_steps.rb
# Step definitions para Feature #99 - Responder Formulário

# Helper method para criar dados de teste
def criar_dados_resposta
  return if @dados_resposta_criados

  # Cria turma única para testes de resposta
  unique_code = "RESP#{Time.now.to_i % 10000}"
  @turma = Turma.find_or_create_by!(codigo: unique_code) do |t|
    t.nome = "Turma Teste Resposta"
    t.semestre = "2024/2"
  end

  # Cria modelo com pergunta usando find_by+build pattern
  @modelo = Modelo.find_by(titulo: "Template Resposta")
  if @modelo.nil?
    @modelo = Modelo.new(titulo: "Template Resposta", ativo: true)
    @modelo.perguntas.build(enunciado: "Como você avalia a disciplina?", tipo: "escala")
    @modelo.save!
  elsif @modelo.perguntas.empty?
    @modelo.perguntas.create!(enunciado: "Como você avalia a disciplina?", tipo: "escala")
  end

  # Cria avaliação ativa
  @avaliacao = Avaliacao.find_or_create_by!(turma: @turma, modelo: @modelo) do |a|
    a.data_inicio = 1.day.ago
    a.data_fim = 7.days.from_now
  end

  # Matricula o usuário na turma (se @user existe)
  if @user && @turma
    MatriculaTurma.find_or_create_by!(user: @user, turma: @turma) do |m|
      m.papel = "Discente"
    end
  end

  @dados_resposta_criados = true
end

When('preencho todas as perguntas obrigatórias da avaliação') do
  criar_dados_resposta

  # Navega para a página de resposta
  visit new_avaliacao_resposta_path(@avaliacao)

  # Preenche as perguntas
  @modelo.perguntas.each_with_index do |pergunta, index|
    case pergunta.tipo
    when 'escala'
      # Seleciona uma opção na escala (radio buttons)
      choose("submissao_respostas_attributes_#{index}_conteudo_4") rescue fill_in "submissao[respostas_attributes][#{index}][conteudo]", with: "4"
    when 'texto_longo', 'texto_curto'
      fill_in "submissao[respostas_attributes][#{index}][conteudo]", with: "Resposta de teste"
    when 'multipla_escolha'
      first("input[name='submissao[respostas_attributes][#{index}][conteudo]']").click rescue fill_in "submissao[respostas_attributes][#{index}][conteudo]", with: "Opção 1"
    else
      fill_in "submissao[respostas_attributes][#{index}][conteudo]", with: "Resposta"
    end
  end
end

When('envio a avaliação') do
  click_button 'Enviar' rescue click_button 'Enviar Avaliação'
end

Then('as respostas devem ser registradas no banco de dados') do
  # Verifica que submissão foi criada
  submissao = Submissao.find_by(avaliacao: @avaliacao, aluno: @user)
  expect(submissao).to be_present
  expect(submissao.respostas.count).to be > 0
end

Then('devo ver uma mensagem de confirmação de envio') do
  expect(page.text).to match(/sucesso|Obrigado|enviado|confirmado/i)
end

When('tento enviar a avaliação com perguntas em branco') do
  criar_dados_resposta

  # Navega para a página de resposta
  visit new_avaliacao_resposta_path(@avaliacao)

  # Não preenche nada, apenas tenta enviar
  click_button 'Enviar' rescue click_button 'Enviar Avaliação'
end

Then('o envio deve ser impedido') do
  # Verifica que ainda está na página de resposta ou recebeu erro
  expect(page).to have_css("form")
end

Then('devo ver uma mensagem informando que existem perguntas obrigatórias não respondidas') do
  expect(page.text).to match(/obrigatórias|responda|preencha|erro/i)
end

# Step for context - creates avaliacao ativa
Dado('que existe uma avaliação ativa para minha turma') do
  criar_dados_resposta
end

Dado('que existe uma avaliação com prazo expirado para minha turma') do
  # Cria turma única
  unique_code = "EXP#{Time.now.to_i % 10000}"
  @turma = Turma.find_or_create_by!(codigo: unique_code) do |t|
    t.nome = "Turma Expirada"
    t.semestre = "2024/1"
  end

  # Matricula o aluno
  if @user && @turma
    MatriculaTurma.find_or_create_by!(user: @user, turma: @turma) do |m|
      m.papel = "Discente"
    end
  end

  # Cria modelo com pergunta
  @modelo = Modelo.find_by(titulo: "Template Expirado")
  if @modelo.nil?
    @modelo = Modelo.new(titulo: "Template Expirado", ativo: true)
    @modelo.perguntas.build(enunciado: "Questão expirada", tipo: "escala")
    @modelo.save!
  end

  # Cria avaliação com prazo EXPIRADO
  @avaliacao_expirada = Avaliacao.create!(
    turma: @turma,
    modelo: @modelo,
    data_inicio: 30.days.ago,
    data_fim: 1.day.ago  # Prazo já passou!
  )
end

Quando('tento acessar a avaliação expirada') do
  visit new_avaliacao_resposta_path(@avaliacao_expirada)
end

Então('não devo conseguir acessar o formulário') do
  # Não deve mostrar formulário de resposta ou deve redirecionar
  # Usar has_button? que retorna boolean em vez de matcher
  has_submit = page.has_button?("Enviar") || page.has_button?("Enviar Avaliação")
  has_expired_msg = page.text.match?(/expirad|encerrad|prazo|não disponível/i)

  # Se expirou, ou não deve ter botão de enviar ou deve ter mensagem de expirado
  expect(has_expired_msg || !has_submit).to be true
end

Então('devo ver uma mensagem indicando que o prazo foi encerrado') do
  expect(page.text).to match(/expirad|encerrad|prazo|finaliz|não disponível/i)
end


Dado('que eu já respondi a uma avaliação da minha turma') do
  criar_dados_resposta

  # Cria submissão (simula que o aluno já respondeu)
  @submissao_existente = Submissao.find_or_create_by!(avaliacao: @avaliacao, aluno: @user) do |s|
    s.data_envio = Time.now
  end

  # Cria resposta para a submissão
  @modelo.perguntas.each do |pergunta|
    Resposta.find_or_create_by!(submissao: @submissao_existente, pergunta: pergunta) do |r|
      r.conteudo = "5"
    end
  end
end

Quando('tento acessar novamente a mesma avaliação') do
  visit new_avaliacao_resposta_path(@avaliacao)
end

Então('não devo conseguir responder novamente') do
  # O sistema deve impedir nova resposta - pode não mostrar formulário ou redirecionar
  # Verificamos que não há formulário ativo para submissão nova
  has_form = page.has_button?("Enviar") || page.has_button?("Enviar Avaliação")
  has_message = page.text.match?(/já respondeu|já enviada|respondido/i)

  expect(has_message || !has_form).to be true
end

Então('devo ver uma mensagem indicando que a avaliação já foi respondida') do
  expect(page.text).to match(/já respondeu|já enviada|respondido|submetid/i)
end
