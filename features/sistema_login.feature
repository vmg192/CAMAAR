# language: pt
#3 pontos

Funcionalidade: Sistema de Login #104
    Eu como Usuário do sistema
    Quero acessar o sistema utilizando um e-mail ou matrícula e uma senha já cadastrada
    A fim de responder formulários ou gerenciar o sistema

    Contexto:
        Dado que estou na pagina "login"

    @104.1
    Esquema do Cenário: Login com sucesso (Aluno e Admin)
        Quando preencho o campo "Login" com "<login>"
        E preencho o campo "Senha" com "<senha>"
        E clico em "Entrar"
        Então devo ser redirecionado para a pagina "<pagina_destino>"
        E devo visualizar a mensagem "Login realizado com sucesso"

        Exemplos:
          | login    | senha    | pagina_destino |
          | aluno123 | senha123 | avaliacoes     |
          | admin    | password | inicial        |

    @104.2
    Esquema do Cenário: Tentativa de login inválida
        Quando preencho o campo "Login" com "<login>"
        E preencho o campo "Senha" com "<senha>"
        E clico em "Entrar"
        Então devo visualizar a mensagem "Falha na autenticação. Usuário ou senha inválidos."

        Exemplos:
          | login                | senha      |
          | hellowor@gmail.com   | worldhello |
          | helloworld@gmail.com | hello      |
          | 876543210            | worldhello |
          | 012345678            | hello      |

    @104.3
    Cenário: Usuario tenta entrar sem nenhum campo de login preenchido
        Dado que os campos de login nao estao preenchidos
        E clico em "Entrar"
        Então devo visualizar a mensagem "Falha na autenticação. Usuário ou senha inválidos."
