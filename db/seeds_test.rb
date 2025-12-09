# db/seeds_test.rb - Dados de teste para verificar fluxo
puts "Criando dados de teste..."

# 1. Criar aluno
aluno = User.create!(
  login: 'aluno123',
  email_address: 'aluno@test.com',
  matricula: '123456789',
  nome: 'João da Silva',
  password: 'senha123',
  password_confirmation: 'senha123',
  eh_admin: false
)
puts "✅ Aluno criado: #{aluno.nome} (login: #{aluno.login})"

# 2. Criar turma
turma = Turma.create!(
  codigo: 'CIC0004',
  nome: 'Engenharia de Software',
  semestre: '2024.2'
)
puts "✅ Turma criada: #{turma.nome}"

# 3. Criar professor
professor = User.create!(
  login: 'prof',
  email_address: 'prof@test.com',
  matricula: '999999',
  nome: 'Prof. Maria',
  password: 'senha123',
  password_confirmation: 'senha123',
  eh_admin: false
)
puts "✅ Professor criado: #{professor.nome}"

# 4. Matricular aluno na turma
MatriculaTurma.create!(
  user: aluno,
  turma: turma,
  papel: 'Discente'
)
puts "✅ Aluno matriculado na turma"

# 5. Matricular professor na turma
MatriculaTurma.create!(
  user: professor,
  turma: turma,
  papel: 'Docente'
)
puts "✅ Professor matriculado na turma"

# 6. Criar avaliação usando o modelo padrão
modelo = Modelo.first
avaliacao = Avaliacao.create!(
  turma: turma,
  modelo: modelo,
  professor_alvo: professor,
  data_inicio: Time.current,
  data_fim: 7.days.from_now
)
puts "✅ Avaliação criada (ID: #{avaliacao.id})"
puts "   Modelo: #{modelo.titulo}"
puts "   #{modelo.perguntas.count} perguntas"
puts ""
puts "🎉 DADOS DE TESTE CRIADOS COM SUCESSO!"
puts ""
puts "=== CREDENCIAIS ==="
puts "Admin: login=admin, senha=password"
puts "Aluno: login=aluno123, senha=senha123"
puts "Professor: login=prof, senha=senha123"
