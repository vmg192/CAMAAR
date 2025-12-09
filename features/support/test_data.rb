# features/support/test_data.rb
# Cria dados de teste necessarios para os cenarios BDD

Before do
  # Garante que admin existe
  User.find_or_create_by!(login: 'admin') do |user|
    user.email_address = 'admin@camaar.com'
    user.password = 'password'
    user.nome = 'Administrador'
    user.matricula = '000000000'
    user.eh_admin = true
  end

  # Garante que aluno existe
  User.find_or_create_by!(login: 'aluno123') do |user|
    user.email_address = 'aluno@test.com'
    user.password = 'senha123'
    user.nome = 'Joao da Silva'
    user.matricula = '123456789'
    user.eh_admin = false
  end

  # Garante que professor existe
  User.find_or_create_by!(login: 'prof') do |user|
    user.email_address = 'prof@test.com'
    user.password = 'senha123'
    user.nome = 'Prof. Maria'
    user.matricula = '999999'
    user.eh_admin = false
  end
end
