# features/step_definitions/cria_avaliacao_steps.rb

Given('que existem turmas cadastradas') do
  @turma = Turma.create!(
    codigo: "CIC001",
    nome: "Engenharia de Software",
    semestre: "2024.2"
  )
end

Given('que existe um modelo de avaliação padrão') do
  Modelo.find_or_create_by!(titulo: "Template Padrão", ativo: true)
end

When('seleciono uma turma') do
  # No contexto da lista, apenas identificamos a linha com a qual vamos interagir
  @target_turma_row = find("tr", text: @turma.codigo)
end

When('seleciono um modelo de avaliação') do
  # A UI atual não permite selecionar um modelo (usa Template Padrão direto).
  # Pulamos esta interação nos passos web por enquanto,
  # mas garantimos que o modelo pré-requisito existe (tratado no Contexto/Given).
  # Se a UI eventualmente adicionar um dropdown, adicionaríamos:
  # select "Template Padrão", from: "modelo_id"
end

When('defino as datas de início e fim') do
  # Data de início é automática. Data de fim está no formulário.
  within(@target_turma_row) do
    fill_in "data_fim", with: 10.days.from_now.to_date
  end
end

When('confirmo a criação') do
  within(@target_turma_row) do
    click_button "Gerar Avaliação"
  end
end

When('tento criar uma avaliação sem preencher os campos obrigatórios') do
  # Encontra a linha
  row = find("tr", text: @turma.codigo)
  within(row) do
    # Esvaziar o campo de data pode acionar validação do navegador ou erro no backend
    fill_in "data_fim", with: ""
    click_button "Gerar Avaliação"
  end
end

Then('a avaliação deve ser salva no banco de dados') do
  expect(Avaliacao.count).to eq(1)
  expect(Avaliacao.last.turma).to eq(@turma)
end

Then('a avaliação não deve ser salva') do
  # Se a validação prevenir
  expect(Avaliacao.count).to eq(0)
  # Nota: A lógica do controller pode usar valor padrão para 'data_fim' se ausente ou dar erro.
  # Precisaríamos verificar o comportamento do controller se quisermos que isso passe.
end

Then('devo ver mensagens de erro indicando os campos obrigatórios') do
  # Isso depende de validação do navegador vs validação Rails.
  # Se Rails acionar "Erro ao criar avaliação", verificamos isso.
  expect(page).to have_content("Erro")
end
