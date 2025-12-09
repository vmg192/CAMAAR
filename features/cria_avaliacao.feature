# language: pt
@testes
@admim
@cria_form

Funcionalidade: Criar formulário de avaliação #103
    Eu como Administrador
    Quero criar um formulário baseado em um template para as turmas que eu escolher
    A fim de avaliar o desempenho das turmas no semestre atual

    Contexto:
        Dado que um "administrador" está logado
        E que existem turmas cadastradas
        E que existe um modelo de avaliação padrão
        E está na tela "Gestão de Envios"

    @103.1
    Cenário: 103.1 - Quando um administrador tenta criar um formulário, com templates carregados no banco de dados, e ele preenche todos os campos corretamente, deve criar um formulário com sucesso.
        Quando seleciono uma turma
        E seleciono um modelo de avaliação
        E defino as datas de início e fim
        E confirmo a criação
        Então a avaliação deve ser salva no banco de dados
        E devo ver a mensagem "Avaliação criada com sucesso"
