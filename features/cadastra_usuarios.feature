# language: pt
#2 pontos

Funcionalidade: Cadastrar usuários do sistema #100 
    Eu como Administrador
    Quero cadastrar participantes de turmas do SIGAA ao importar dados de usuarios novos para o sistema
    A fim de que eles acessem o sistema

    # Nota: O cadastro de usuários acontece automaticamente durante a importação de dados do SIGAA (Feature #98).
    # Os usuários são criados com senhas temporárias exibidas na tela de sucesso.

    Contexto:
        Dado que o o banco de dados está "vazio"
        E que está na tela "Gerenciamento"

    @100.1
    Cenário: 100.1 - Quando um Administrador tenta registrar novos usuários do Sigaa, deve salvar os novos alunos no banco de dados e enviar emails para cadastrar a senha.
        Quando importo um arquivo de dados do SIGAA contendo novos usuários
        Então os novos usuários devem ser salvos no banco de dados
        E um email de boas-vindas deve ser enviado para cada um
