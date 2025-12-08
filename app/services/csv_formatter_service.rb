require 'csv'

class CsvFormatterService
  def initialize(avaliacao)
    @avaliacao = avaliacao
  end

  def generate
    CSV.generate(headers: true) do |csv|
      csv << headers

      @avaliacao.respostas.includes(:aluno).group_by(&:aluno).each do |aluno, respostas|
        row = [aluno.matricula, aluno.nome]
        
        # Organiza as respostas pela ordem das questões se possível, ou mapeamento simples
        # Assumindo que queremos mapear questões para colunas
        
        # Para este MVP, vamos apenas despejar o conteúdo na ordem das questões encontradas
        # Uma solução mais robusta ordenaria por ID da questão ou número
        
        respostas.each do |resposta|
          row << resposta.conteudo
        end
        
        csv << row
      end
    end
  end

  private

  def headers
    # Cabeçalhos estáticos para informações do Aluno
    base_headers = ["Matrícula", "Nome"]
    
    # Cabeçalhos dinâmicos para questões
    # Identificando questões únicas respondidas ou todas as questões do modelo
    # Para o MVP, vamos assumir que queremos todas as questões do modelo
    
    questoes = @avaliacao.modelo.perguntas
    question_headers = questoes.map.with_index { |q, i| "Questão #{i + 1}" }
    
    base_headers + question_headers
  end
end
