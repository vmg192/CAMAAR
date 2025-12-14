# language: pt
#2 pontos

Funcionalidade: Responder formulário #99
    Eu como Participante de uma turma
    Quero responder o questionário sobre a turma em que estou matriculado
    A fim de submeter minha avaliação da turma

    Contexto:
        Dado que um "participante" está logado

    @99.1
    Cenário: 99.1 - Quando um Participante preenche e envia corretamente o formulário, o sistema deve registrar as respostas no banco de dados e confirmar o envio.
        Dado que existe uma avaliação ativa para minha turma
        Quando preencho todas as perguntas obrigatórias da avaliação
        E envio a avaliação
        Então as respostas devem ser registradas no banco de dados
        E devo ver uma mensagem de confirmação de envio

    @99.2
    Cenário: 99.2 - Quando um Participante tenta enviar o formulário sem completar todas as perguntas obrigatórias, o sistema deve impedir o envio e informar sobre perguntas pendentes.
        Dado que existe uma avaliação ativa para minha turma
        Quando tento enviar a avaliação com perguntas em branco
        Então o envio deve ser impedido
        E devo ver uma mensagem informando que existem perguntas obrigatórias não respondidas

    @99.3
    Cenário: 99.3 - Quando um Participante tenta responder uma avaliação após o prazo, o sistema deve impedir o acesso.
        Dado que existe uma avaliação com prazo expirado para minha turma
        Quando tento acessar a avaliação expirada
        Então não devo conseguir acessar o formulário
        E devo ver uma mensagem indicando que o prazo foi encerrado

    @99.4
    Cenário: 99.4 - Quando um Participante tenta responder uma avaliação que já respondeu, o sistema deve informar que já foi submetida.
        Dado que eu já respondi a uma avaliação da minha turma
        Quando tento acessar novamente a mesma avaliação
        Então não devo conseguir responder novamente
        E devo ver uma mensagem indicando que a avaliação já foi respondida
