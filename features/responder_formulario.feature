# language: pt
#2 pontos

Funcionalidade: Responder formulário #99
    Eu como Participante de uma turma
    Quero responder o questionário sobre a turma em que estou matriculado
    A fim de submeter minha avaliação da turma

    Contexto:
        Dado que um "participante" está logado
        E está na tela 'Avaliação da Turma'

    @99.1
    Cenário: 99.1 – Quando um Participante preenche e envia corretamente o formulário, o sistema deve registrar as respostas no banco de dados e confirmar o envio.
        Quando preencho todas as perguntas obrigatórias da avaliação
        E envio a avaliação
        Então as respostas devem ser registradas no banco de dados
        E devo ver uma mensagem de confirmação de envio

    @99.2
    Cenário: 99.2 – Quando um Participante tenta enviar o formulário sem completar todas as perguntas obrigatórias, o sistema deve impedir o envio e informar sobre perguntas pendentes.
        Quando tento enviar a avaliação com perguntas em branco
        Então o envio deve ser impedido
        E devo ver uma mensagem informando que existem perguntas obrigatórias não respondidas
