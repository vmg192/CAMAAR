require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "usuario valido deve ser salvo" do
    usuario = User.new(
      login: "teste_unitario",
      email_address: "teste@unitario.com",
      matricula: "999999",
      nome: "Joao Teste",
      formacao: "Engenharia",
      password_digest: "senha123",
      eh_admin: false
    )
    assert usuario.save, "Nao salvou o usuario valido"
  end

  test "nao deve salvar usuario sem login" do
    usuario = User.new(email_address: "sem_login@teste.com", password_digest: "123")
    assert_not usuario.save, "Salvou usuario sem login"
  end
end
