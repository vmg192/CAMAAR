require 'json'
require 'csv'

class SigaaImportService
  def initialize(file_path)
    @file_path = file_path
    @results = {
      turmas_created: 0,
      turmas_updated: 0,
      usuarios_created: 0,
      usuarios_updated: 0,
      errors: []
    }
  end

  def process
    unless File.exist?(@file_path)
      @results[:errors] << "Arquivo não encontrado: #{@file_path}"
      return @results
    end

    begin
      ActiveRecord::Base.transaction do
        case File.extname(@file_path).downcase
        when '.json'
          process_json
        when '.csv'
          process_csv
        else
          @results[:errors] << "Formato de arquivo não suportado: #{File.extname(@file_path)}"
        end

        if @results[:errors].any?
          raise ActiveRecord::Rollback
        end
      end
    rescue JSON::ParserError
      @results[:errors] << "Arquivo JSON inválido"
    rescue ActiveRecord::StatementInvalid => e
      @results[:errors] << "Erro de conexão com o banco de dados: #{e.message}"
    rescue StandardError => e
      @results[:errors] << "Erro inesperado: #{e.message}"
    end

    @results
  end

  private

  def process_json
    file_content = File.read(@file_path)
    data = JSON.parse(file_content)
    data.each do |turma_data|
      process_turma(turma_data)
    end
  end

  def process_csv
    CSV.foreach(@file_path, headers: true, col_sep: ',') do |row|
      # Assumindo estrutura do CSV
      turma_data = {
        'codigo' => row['codigo_turma'],
        'nome' => row['nome_turma'],
        'semestre' => row['semestre']
      }
      
      turma = process_turma_record(turma_data)
      
      if turma&.persisted?
        user_data = {
          'nome' => row['nome_usuario'],
          'email' => row['email'],
          'matricula' => row['matricula'],
          'papel' => row['papel']
        }
        process_participante_single(turma, user_data)
      end
    end
  end

  def process_turma(data)
    turma = process_turma_record(data)
    if turma&.persisted?
      process_participantes(turma, data['participantes']) if data['participantes']
    end
  end

  def process_turma_record(data)
    turma = Turma.find_or_initialize_by(codigo: data['codigo'], semestre: data['semestre'])
    
    is_new_record = turma.new_record?
    turma.nome = data['nome']
    
    if turma.save
      if is_new_record
        @results[:turmas_created] += 1
      else
        @results[:turmas_updated] += 1
      end
      turma
    else
      @results[:errors] << "Erro ao salvar turma #{data['codigo']}: #{turma.errors.full_messages.join(', ')}"
      nil
    end
  end

  def process_participantes(turma, participantes_data)
    participantes_data.each do |p_data|
      process_participante_single(turma, p_data)
    end
  end

  def process_participante_single(turma, p_data)
    # Usuario identificado pela matrícula
    user = User.find_or_initialize_by(matricula: p_data['matricula'])
    
    is_new_user = user.new_record?
    user.nome = p_data['nome']
    user.email = p_data['email']

    generated_password = nil
    if is_new_user
      generated_password = SecureRandom.hex(8)
      user.password = generated_password
    end

    if user.save
      if is_new_user
        @results[:usuarios_created] += 1
        UserMailer.cadastro_email(user, generated_password).deliver_now
      else
        @results[:usuarios_updated] += 1
      end
      
      matricula = MatriculaTurma.find_or_initialize_by(turma: turma, user: user)
      matricula.papel = p_data['papel']
      matricula.save!
    else
      @results[:errors] << "Erro ao salvar usuário #{p_data['matricula']}: #{user.errors.full_messages.join(', ')}"
    end
  end
end
