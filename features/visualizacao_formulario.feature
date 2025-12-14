# language: pt
@testes
@participante
@visualiza_formularios

Funcionalidade: Visualização de formulários pendentes #109
    Eu como Participante de uma turma
    Quero visualizar os formulários não respondidos das turmas em que estou matriculado
    A fim de poder escolher qual irei responder

    Contexto:
        Dado que um "participante" está logado
        E está na tela 'Principal'

    @109.1
    Cenário: 109.1 - Quando o participante acessa o sistema, deve visualizar os formulários que ainda não respondeu.
        Quando acesso a minha lista de atividades
        Então devo ver as avaliações que ainda não respondi
        E devo ver o nome da turma e data limite de cada uma

    @109.2
    Cenário: 109.2 - Quando um participante seleciona um formulário da lista, deve ser direcionado para respondê-lo.
        Quando clico em uma avaliação pendente
        Então devo ser redirecionado para a tela de resposta daquela avaliação

    @109.3
    Cenário: 109.3 - Quando não existem formulários criados para as turmas do participante, a lista deve estar vazia.
        Dado que já respondi todas as avaliações disponíveis
        Quando acesso a minha lista de atividades
        Então devo ver uma mensagem "Nenhuma atividade pendente"
