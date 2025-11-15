@testes
@admin
@importa_sigaa
@atualiza_dados

#Mesma coisa só que atualiza os dados então tem que ter o banco de dados carregado
#1 ponto

Funcionalidade: Atualizar base de dados com os dados do SIGAA rgba(25, 17, 81, 1)

    Eu como Administrador
    Quero atualizar a base de dados já existente com os dados atuais do sigaa
    A fim de corrigir a base de dados do sistema.   

    Contexto:
        Dado que um 'administrador' está logado
        E está na tela 'Gerenciamento'
        E o banco de dados está 'com coisas'

    @98.1
    Cenário: 98.1 - Quando um administrador tenta importar dados do SIGAA, eles devem ser acrescentados na base de dados
      
    @sla 
    Cenário: se tentar adicionar alguma coisa que já ta no banco de dados não deve adicionar nada e mostrar na tela as mesmas de antes
     


    