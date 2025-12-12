# Admin User
admin = User.find_or_create_by!(login: 'admin') do |u|
  u.email_address = 'admin@camaar.unb.br'
  u.nome = 'Administrador'
  u.matricula = '000000000'
  u.password = 'password'
  u.password_confirmation = 'password'
  u.eh_admin = true
end
puts "Usuário Admin garantido (ID: #{admin.id})"

# Template Padrão
# Garantir que exista pelo menos um modelo com perguntas
puts "Modelo 'Template Padrão' garantido (ID: 1)"
modelo = Modelo.find_or_initialize_by(id: 1)
modelo.assign_attributes(
  titulo: 'Template Padrão',
  ativo: true
)

# Criar perguntas apenas se o modelo for novo ou não tiver perguntas
if modelo.new_record? || modelo.perguntas.empty?
  modelo.perguntas.destroy_all if modelo.persisted? # Limpar perguntas antigas se existir

  modelo.perguntas.build([
    {
      enunciado: 'O professor demonstrou domínio do conteúdo?',
      tipo: 'escala',
      opcoes: { min: 1, max: 5 }
    },
    {
      enunciado: 'As aulas foram bem organizadas?',
      tipo: 'escala',
      opcoes: { min: 1, max: 5 }
    },
    {
      enunciado: 'O material didático foi adequado?',
      tipo: 'escala',
      opcoes: { min: 1, max: 5 }
    },
    {
      enunciado: 'Você recomendaria esta disciplina?',
      tipo: 'multipla_escolha',
      opcoes: [ 'Sim', 'Não', 'Talvez' ]
    },
    {
      enunciado: 'Comentários adicionais (opcional):',
      tipo: 'texto_longo',
      opcoes: nil
    }
  ])
end

modelo.save!
puts "#{modelo.perguntas.count} perguntas garantidas para o Template Padrão."
