# language: pt
@testes
@admim
@download_csv

Funcionalidade: Download de resultados em CSV #101
    Eu como Administrador
    Quero baixar um arquivo csv contendo os resultados de um formulário
    A fim de avaliar o desempenho das turmas

    Contexto:
        Dado que um "administrador" está logado
        E está na tela 'Resultados do Formulário'

    @101.1
    Cenário: 101.1 - Quando um administrador aperta o botão de exportar, deve ser possível baixar o arquivo CSV.
        Quando clico no botão "Exportar para CSV"
        Então o download do arquivo CSV deve iniciar
        E o arquivo deve conter as respostas dos alunos

    @101.2
    Cenário: 101.2 - Se o formulario não estiver preenchido, não deve ser possível fazer o download do CSV.
        Dado que a avaliação selecionada não possui respostas
        Quando tento exportar para CSV
        Então devo ver um alerta informando que não há dados disponíveis
