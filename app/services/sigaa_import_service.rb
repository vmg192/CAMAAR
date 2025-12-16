require "json"
require "csv"

# Serviço para importar dados do SIGAA
# Processa JSON ou CSV com turmas e usuários
class SigaaImportService
  # Inicializa serviço
  # @param file_path [Pathname] Caminho do arquivo class_members.json
  # @param classes_file_path [Pathname] Caminho do arquivo classes.json (opcional)
  def initialize(file_path, classes_file_path = nil)
    @file_path = file_path
    @classes_file_path = classes_file_path
    @results = {
      turmas_created: 0,
      turmas_updated: 0,
      users_created: 0,
      users_updated: 0,
      new_users: [],
      errors: []
    }
  end

  # Processa arquivo e importa dados
  # @return [Hash] Resultados com contagens e erros
  # @efeito_colateral Cria/atualiza Turma, User, MatriculaTurma
  def process
    unless File.exist?(@file_path)
      @results[:errors] << "Arquivo não encontrado: #{@file_path}"
      return @results
    end

    begin
      ActiveRecord::Base.transaction do
        case File.extname(@file_path).downcase
        when ".json"
          process_json
        when ".csv"
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

  # Processa arquivo JSON
  # @return [void]
  def process_json
    data = JSON.parse(File.read(@file_path))
    classes_lookup = build_classes_lookup

    data.each do |turma_data|
      class_key = [ turma_data["code"], turma_data["semester"] ]
      class_name = classes_lookup[class_key] || turma_data["code"]

      normalized_data = {
        "codigo" => turma_data["code"],
        "nome" => class_name,
        "semestre" => turma_data["semester"],
        "participantes" => []
      }

      if turma_data["dicente"]
        turma_data["dicente"].each do |dicente|
          normalized_data["participantes"] << {
            "nome" => dicente["nome"],
            "email" => dicente["email"],
            "matricula" => dicente["matricula"] || dicente["usuario"],
            "papel" => "Discente"
          }
        end
      end

      if turma_data["docente"]
        docente = turma_data["docente"]
        normalized_data["participantes"] << {
          "nome" => docente["nome"],
          "email" => docente["email"],
          "matricula" => docente["usuario"],
          "papel" => "Docente"
        }
      end

      process_turma(normalized_data)
    end
  end

  # Constrói lookup de nomes de turmas
  # @return [Hash] Mapa code+semester => nome
  def build_classes_lookup
    return {} unless @classes_file_path && File.exist?(@classes_file_path)

    begin
      classes_data = JSON.parse(File.read(@classes_file_path))
      classes_data.each_with_object({}) do |item, hash|
        key = [ item["code"], item.dig("class", "semester") ]
        hash[key] = item["name"]
      end
    rescue JSON::ParserError
      @results[:errors] << "Arquivo classes.json inválido"
      {}
    end
  end

  # Processa arquivo CSV
  # @return [void]
  def process_csv
    CSV.foreach(@file_path, headers: true, col_sep: ",") do |row|
      turma_data = {
        "codigo" => row["codigo_turma"],
        "nome" => row["nome_turma"],
        "semestre" => row["semestre"]
      }

      turma = process_turma_record(turma_data)

      if turma&.persisted?
        user_data = {
          "nome" => row["nome_usuario"],
          "email" => row["email"],
          "matricula" => row["matricula"],
          "papel" => row["papel"]
        }
        process_participante_single(turma, user_data)
      end
    end
  end

  # Processa dados de turma
  # @param data [Hash] Dados da turma
  # @return [void]
  def process_turma(data)
    turma = process_turma_record(data)
    if turma&.persisted?
      process_participantes(turma, data["participantes"]) if data["participantes"]
    end
  end

  # Cria/atualiza registro de turma
  # @param data [Hash] Dados da turma
  # @return [Turma, nil]
  def process_turma_record(data)
    turma = Turma.find_or_initialize_by(codigo: data["codigo"], semestre: data["semestre"])

    is_new_record = turma.new_record?
    turma.nome = data["nome"]

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

  # Processa lista de participantes
  # @param turma [Turma]
  # @param participantes_data [Array<Hash>]
  # @return [void]
  def process_participantes(turma, participantes_data)
    participantes_data.each do |p_data|
      process_participante_single(turma, p_data)
    end
  end

  # Processa um participante
  # @param turma [Turma]
  # @param p_data [Hash] Dados do participante
  # @return [void]
  # @efeito_colateral Cria/atualiza User e MatriculaTurma
  def process_participante_single(turma, p_data)
    user = User.find_or_initialize_by(matricula: p_data["matricula"])

    is_new_user = user.new_record?
    user.nome = p_data["nome"]
    user.email_address = p_data["email"]
    user.login = p_data["matricula"] if user.login.blank?

    generated_password = nil
    if is_new_user
      generated_password = SecureRandom.hex(8)
      user.password = generated_password
    end

    if user.save
      if is_new_user
        @results[:users_created] += 1
        @results[:new_users] << {
          matricula: user.matricula,
          nome: user.nome,
          login: user.login,
          password: generated_password,
          email: user.email_address
        }
      else
        @results[:users_updated] += 1
      end

      matricula = MatriculaTurma.find_or_initialize_by(turma: turma, user: user)
      matricula.papel = p_data["papel"]
      matricula.save!
    else
      @results[:errors] << "Erro ao salvar usuário #{p_data['matricula']}: #{user.errors.full_messages.join(', ')}"
    end
  end
end
