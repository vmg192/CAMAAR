# Features/Step_Definitions/Relatorio_Steps.rb

Given('que a avaliação selecionada não possui respostas') do
    @avaliacao_vazia = Avaliacao.create!(turma: @turma, modelo: @modelo, titulo: "Avaliação Vazia", data_inicio: Time.now)
    visit resultados_avaliacao_path(@avaliacao_vazia)
end

When('clico no botão {string}') do |botao|
    click_on botao
end

Then('o download do arquivo CSV deve iniciar') do
    expect(page.response_headers['Content-Type']).to include('text/csv')
end

Then('o arquivo deve conter as respostas dos alunos') do
    # Verify content disposition or partial content
    expect(page.response_headers['Content-Disposition']).to include('attachment')
end

When('tento exportar para CSV') do
    click_on "Exportar para CSV"
end

Then('devo ver um alerta informando que não há dados disponíveis') do
    expect(page).to have_content("Nenhuma resposta encontrada")
end
