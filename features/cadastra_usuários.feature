# language: pt
#2 pontos

Funcionalidade: Cadastrar usuários do sistema #100 
    Eu como Administrador
    Quero cadastrar participantes de turmas do SIGAA ao importar dados de usuarios novos para o sistema
    A fim de que eles acessem o sistema

    # Nesta issue é importante lembrar que apesar de estar sendo citado como cadastro de usuário, o que é feito é a solicitação da definição da senha do usuário.
    # O cadastro do aluno/professor como usuário só é realmente efetivado após a definição da senha.

    Contexto:
        Dado que o o banco de dados está "vazio"
        E que está na tela "Gerenciamento"

    @100.1
    Cenário: 100.1 - Quando um Administrador tenta registrar novos usuários do Sigaa, deve salvar os novos alunos no banco de dados e enviar emails para cadastrar a senha.
        Quando importo um arquivo de dados do SIGAA contendo novos usuários
        Então os novos usuários devem ser salvos no banco de dados
        E um email de boas-vindas deve ser enviado para cada um

    @100.2
    Cenário:  100.2 - Quando um Administrador tenta cadastrar estudantes já cadastrados, o sistema deve retornar uma mensagem informando que não há novos usuários a serem cadastrados.
        Quando importo um arquivo contendo apenas usuários já cadastrados
        Então nenhum novo usuário deve ser criado
        E devo ver uma mensagem informando que os usuários já existem

    @100.3
    Cenário: 100.3 - Quando um Administrador tenta adicionar novos estudantes mas não existem alunos nos dados do SIGAA deve exibir mensagem indicando que o arquivo está vazio.
        Quando importo um arquivo vazio ou sem dados de usuários
        Então nenhum usuário deve ser cadastrado
        E devo ver uma mensagem de erro indicando arquivo vazio
