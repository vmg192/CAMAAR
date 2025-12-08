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
modelo = Modelo.find_or_create_by!(titulo: 'Template Padrão') do |m|
  m.ativo = true
end
puts "Modelo 'Template Padrão' garantido (ID: #{modelo.id})"

# Perguntas do Template Padrão
perguntas_data = [
  { enunciado: 'O professor demonstrou domínio do conteúdo?', tipo: 'escala', opcoes: { min: 1, max: 5 } },
  { enunciado: 'O plano de ensino foi seguido?', tipo: 'escala', opcoes: { min: 1, max: 5 } },
  { enunciado: 'Como você avalia a didática do professor?', tipo: 'escala', opcoes: { min: 1, max: 5 } },
  { enunciado: 'Pontos positivos:', tipo: 'texto', opcoes: {} },
  { enunciado: 'Pontos a melhorar:', tipo: 'texto', opcoes: {} }
]

perguntas_data.each do |p_data|
  Pergunta.find_or_create_by!(modelo: modelo, enunciado: p_data[:enunciado]) do |p|
    p.tipo = p_data[:tipo]
    p.opcoes = p_data[:opcoes]
  end
end
puts "#{modelo.perguntas.count} perguntas garantidas para o Template Padrão."
