require "test_helper"

class UsuarioTest < ActiveSupport::TestCase
  test "usuario valido deve ser salvo" do
    usuario = Usuario.new(
      login: "teste_unitario",
      email: "teste@unitario.com",
      matricula: "999999",
      nome: "Joao Teste",
      formacao: "Engenharia",
      password: "senha123",
      eh_admin: false
    )
    assert usuario.save, "Nao salvou o usuario valido"
  end

  test "nao deve salvar usuario sem login" do
    usuario = Usuario.new(email: "sem_login@teste.com", password: "123")
    assert_not usuario.save, "Salvou usuario sem login"
  end
end
