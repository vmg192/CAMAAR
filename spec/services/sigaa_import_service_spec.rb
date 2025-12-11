require 'rails_helper'

RSpec.describe SigaaImportService, type: :service do
  let(:json_path) { Rails.root.join('spec/fixtures/turmas.json') }
  let(:csv_path) { Rails.root.join('spec/fixtures/turmas.csv') }
  let(:invalid_path) { Rails.root.join('spec/fixtures/invalid.txt') }

  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:read).with(json_path).and_return([
      {
        'codigo' => 'T01',
        'nome' => 'Engenharia de Software',
        'semestre' => '2024.1',
        'participantes' => [
          {
            'matricula' => '123456',
            'nome' => 'João Silva',
            'email' => 'joao@example.com',
            'papel' => 'aluno'
          }
        ]
      }
    ].to_json)

    allow(CSV).to receive(:foreach).with(csv_path, headers: true, col_sep: ',').and_yield(
      CSV::Row.new(%w[codigo_turma nome_turma semestre nome_usuario email matricula papel],
                   ['T02', 'Banco de Dados', '2024.1', 'Maria Souza', 'maria@example.com', '654321', 'professor'])
    )

    allow(File).to receive(:extname).with(json_path).and_return('.json')
    allow(File).to receive(:extname).with(csv_path).and_return('.csv')
    allow(File).to receive(:extname).with(invalid_path).and_return('.txt')
  end

  class DummyMessage
    def deliver_now
      true
    end
  end

  class DummyMailer
    def self.cadastro_email(user, password)
      DummyMessage.new
    end
  end

  describe '#process' do
    context 'with JSON file' do
      it 'creates turmas and users' do
        Turma.delete_all
        User.delete_all

        service = SigaaImportService.new(json_path, mailer: DummyMailer)
        result = service.process
        puts "JSON Import Errors: #{result[:errors]}" if result[:errors].any?

        expect(Turma.count).to eq(1)
        expect(User.count).to eq(1)
      end
    end

    context 'with CSV file' do
      it 'creates turmas and users' do
        Turma.delete_all
        User.delete_all

        service = SigaaImportService.new(csv_path, mailer: DummyMailer)
        result = service.process
        puts "CSV Import Errors: #{result[:errors]}" if result[:errors].any?

        expect(Turma.count).to eq(1)
        expect(User.count).to eq(1)
      end
    end

    context 'with unsupported file format' do
      it 'returns error' do
        service = SigaaImportService.new(invalid_path, mailer: DummyMailer)
        result = service.process
        unless result[:errors].join(', ').include?('Formato de arquivo não suportado')
          raise "Expected error 'Formato de arquivo não suportado' not found in: #{result[:errors]}"
        end
      end
    end
  end
end
