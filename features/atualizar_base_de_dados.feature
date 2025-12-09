# language: pt
@testes
@admim
@importa_sigaa
@atualiza_sigaa

Funcionalidade: Atualizar base de dados com SIGAA #108
    Eu como Administrador
    Quero atualizar a base de dados já existente com os dados atuais do sigaa
    A fim de corrigir a base de dados do sistema.

    Contexto:
        Dado que um "administrador" está logado
        E está na tela 'Gerenciamento'

    @108.1
    Cenário: 108.1 - Quando um administrador tenta atualizar a base de dados com o SIGAA, os dados devem ser corrigidos na base de dados
        Quando faço upload de um arquivo CSV do SIGAA com dados atualizados
        E confirmo a operação
        Então os registros existentes devem ser atualizados no banco de dados
        E devo ver um resumo das alterações realizadas

    @108.2
    Cenário: 108.2 - Quando um administrador tenta atualizar a base de dados com o SIGAA, mas os dados fornecidos forem inválidos, então deve mostrar mensagem de erro
        Quando faço upload de um arquivo inválido para atualização
        Então os dados não devem ser alterados
        E devo ver uma mensagem de erro de formato
