# language: pt
@testes
@admim
@visualiza_template


Funcionalidade: Visualização dos templates criados #111
    Eu como Administrador
    Quero visualizar os templates criados
    A fim de poder editar e/ou deletar um template que eu criei

    Contexto:
        Dado que um 'administrador' está logado
        E está na tela 'Templates'
        E o banco de dados está 'carregado'

    @111.1
    Cenário: 111.1 - Quando um administrador seleciona o botão de editar um template, deve ser possível visualizar e editar o template.
        Quando o botão de edição de um formulário é selecionado
        Entao deve ser possível visualizar o template selecionado
        Quando o template é editado 'corretamente'
        Entao deve salvar o template no banco de dados

    @111.2
    Cenário: 111.2 - Quando um administrador tenta editar  um template mas preenche os dados incorretamente, não deve alterar os templates do banco de dados.
        Quando o botão de edição de um formulário é selecionado
        Entao deve ser possível visualizar o template selecionado
        Quando o template é editado 'incorretamente'
        Entao não deve alterar o template no banco de dados

    @111.3
    Cenário: 111.3 - Quando um administrador seleciona o botão de excluir um template, o template deve ser removido do banco de dados.
        Quando o botão de remoção de um template é selecionado
        Entao o template deve ser excluído do banco de dados

    @111.4 
    Cenário: 111.4 - Sem templates salvos no banco de dados, não deve ser possível visualizar os templates
        Quando o banco de dados não tem 'template' salvo
        E está na tela 'Gerenciamento'
        E tenta ir para a tela de 'Templates' da tela de 'Gerenciamento'
        Entao deve permanecer na tela 'Gerenciamento'

    
        

   