# language: pt
#1 ponto
Funcionalidade: Redefinição de senha #107
    Eu como Usuário
    Quero redefinir uma senha para o meu usuário a partir do e-mail recebido após a solicitação da troca de senha
    A fim de recuperar o meu acesso ao sistema
    
    Contexto:
        Dado que existe um usuario registrado com: 
        |       email       | 
        |"whoami@gmail.com" |
        E estou na tela de login

    @107.1
    Cenário: 107.1 - Usuario fornece um email cadastrado
        Quando eu preencher o campo "email_ou_matricula" com "whoami@gmail.com"
        E clicar em "Esqueceu a senha?"
        Entao devo visualizar a mensagem "Se existir uma conta associada a whoami@gmail.com, enviamos instruções para redefinir sua senha. Por favor, verifique sua caixa de entrada e a de spam."
        Quando eu verificar meu email devo ter recebido um link para a redefinir a minha senha
        Quando eu clicar no link
        Entao devo ser redirecionado para a pagina "redefinicao de senha"
    
    @107.2
    Cenário: 107.2 - Usuario fornece um email que nao esta cadastrado
        Quando eu preencher o campo "email_ou_matricula" com "nobody@gmail.com"
        E clicar em "Esqueceu a senha?"
        Entao devo visualizar a mensagem "Se existir uma conta associada a nobody@gmail.com, enviamos instruções para redefinir sua senha. Por favor, verifique sua caixa de entrada e a de spam."
        E apos a verificacao de cadastrato nenhum email deve ser enviado para o email utilizado
    
    @107.3
    Cenário: 107.3 - Usuario nao fornece um email valido
        Dado que tenha preenchido o campo "email_ou_matricula" com algum dado que nao seja um email
        Quando eu clicar em "Esqueceu a senha?"
        Entao devo visualizar a mensagem "Para redefinição de senha, o campo e-mail ou matrícula deve ser preenchido com um e-mail válido."


