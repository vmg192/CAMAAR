# language: pt
@testes
@admim
@importa_sigaa

Funcionalidade: Importar dados do SIGAA #98
    Eu como Administrador
    Quero importar dados de turmas, matérias e participantes do SIGAA (caso não existam na base de dados atual)
    A fim de alimentar a base de dados do sistema.

    Contexto:
        Dado que um "administrador" está logado
        E está na tela 'Gerenciamento'

    @98.1
    Cenário: 98.1 - Quando um administrador tenta importar novos dados do SIGAA, eles devem ser salvos na base de dados
        Quando importo dados do SIGAA
        Então os dados de turmas e usuários devem ser salvos no banco de dados
        E devo ver um resumo da importação com sucesso

    @98.2
    Cenário: 98.2 - Quando um administrador tenta importar novos dados do SIGAA, mas os dados fornecidos forem inválidos
        Quando tento importar dados inválidos do SIGAA
        Então nenhum dado deve ser salvo no banco de dados
        E não devo ver informações novas na tela