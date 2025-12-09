# language: pt
@testes  
@admin  
@visualizacao_formularios  
@relatorios

Funcionalidade: Visualização de resultados dos formulários #110  
    Eu como: Administrador  
    Quero: visualizar os formulários criados  
    A fim de: poder gerar um relatório a partir das respostas  

    Contexto:
        Dado que um "administrador" está logado
        E está na tela 'Relatórios'

    @110.1
    Cenário: 110.1 - Quando um administrador visualiza formulários existentes, deve carregar a lista corretamente
        Quando acesso a lista de avaliações
        Então devo ver todas as avaliações cadastradas
        E devo ver o título, data de criação e status de cada uma

    @110.2
    Cenário: 110.2 - Quando um administrador gera relatório a partir das respostas (Visualizar detalhes)
        Quando clico em uma avaliação na lista
        Então devo ver os detalhes da avaliação
        E devo ver a lista de submissões dos alunos

    @110.3
    Cenário: 110.3 - Quando um administrador tenta visualizar formulários mas não existem formulários criados
        Dado que não existem avaliações cadastradas
        Quando acesso a lista de avaliações
        Então devo ver uma mensagem "Nenhuma avaliação encontrada"
