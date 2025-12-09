# features/step_definitions/visualizacao_formulario_steps.rb

# Feature 109 - Visualizar Formulários Pendentes (Perspectiva do Aluno)

Quando('acesso a minha lista de atividades') do
  # Para o MVP, isso pode estar na página raiz para alunos
  visit root_path
end

Então('devo ver as avaliações que ainda não respondi') do
  # Deve ver cards/itens de lista de avaliações - depende da Feature 99
  pending "Dashboard do aluno não totalmente implementado - Dependência da Feature 99"
end

Então('devo ver o nome da turma e data limite de cada uma') do
  pending "Feature 99 (Responder) ainda não foi totalmente implementada"
end

Quando('clico em uma avaliação pendente') do
  pending "Feature 99 (Responder) ainda não foi totalmente implementada"
end

Então('devo ser redirecionado para a tela de resposta daquela avaliação') do
  pending "Feature 99 (Responder) ainda não foi totalmente implementada"
end

Dado('que já respondi todas as avaliações disponíveis') do
  pending "Feature 99 (Responder) ainda não foi totalmente implementada"
end

Então('devo ver uma mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
