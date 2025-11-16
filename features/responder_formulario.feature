# language: pt

@testes
@estudante
@preencher_formulário

#99
#2 pontos
Funcionalidade: Responder formulário #99
    Eu como Participante de uma turma
    Quero responder o questionário sobre a turma em que estou matriculado
    A fim de submeter minha avaliação da turma

    Contexto:
        Dado que um 'administrador' está logado
        E está na tela ''


    @99.1
    Cenário: 99.1 - deu tudo certo

    @99.2
    Cenário: falha no envio por não completar o formulário

    @99.3
    Cenário: falha no envio por problema no banco de dados 

    


    