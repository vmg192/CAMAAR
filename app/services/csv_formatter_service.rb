require "csv"

class CsvFormatterService
  def initialize(avaliacao)
    @avaliacao = avaliacao
  end

  def generate
    CSV.generate(headers: true) do |csv|
      csv << headers

      @avaliacao.submissoes.includes(:aluno, :respostas).each do |submissao|
        # Usar ID anônimo em vez do nome/matrícula do aluno para privacidade
        row = [ submissao.id ]

        # Organiza as respostas pela ordem das questões se possível, ou mapeamento simples
        # Assumindo que queremos mapear questões para colunas

        # Para este MVP, vamos apenas despejar o conteúdo na ordem das questões encontradas
        # Uma solução mais robusta ordenaria por ID da questão ou número

        submissao.respostas.each do |resposta|
          row << resposta.conteudo
        end

        csv << row
      end
    end
  end

  private

  def headers
    # Cabeçalho anônimo (sem identificação do aluno para privacidade)
    base_headers = [ "Submissão" ]

    # Cabeçalhos dinâmicos para questões
    # Identificando questões únicas respondidas ou todas as questões do modelo
    # Para o MVP, vamos assumir que queremos todas as questões do modelo

    questoes = @avaliacao.modelo.perguntas
    question_headers = questoes.map.with_index { |q, i| "Questão #{i + 1}" }

    base_headers + question_headers
  end
end
