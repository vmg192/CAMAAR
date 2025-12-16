require "csv"

# Serviço para gerar CSV com resultados de avaliação
class CsvFormatterService
  # Inicializa com avaliação
  # @param avaliacao [Avaliacao] Avaliação para exportar
  def initialize(avaliacao)
    @avaliacao = avaliacao
  end

  # Gera string CSV com respostas
  # @return [String] Conteúdo CSV formatado
  def generate
    CSV.generate(headers: true) do |csv|
      csv << headers

      @avaliacao.submissoes.includes(:aluno, :respostas).each do |submissao|
        row = [ submissao.id ]

        submissao.respostas.each do |resposta|
          row << resposta.conteudo
        end

        csv << row
      end
    end
  end

  private

  # Gera cabeçalhos do CSV
  # @return [Array<String>] Lista de cabeçalhos
  def headers
    base_headers = [ "Submissão" ]

    questoes = @avaliacao.modelo.perguntas
    question_headers = questoes.map.with_index { |q, i| "Questão #{i + 1}" }

    base_headers + question_headers
  end
end
