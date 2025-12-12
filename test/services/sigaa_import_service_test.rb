# require "test_helper"

# class SigaaImportServiceTest < ActiveSupport::TestCase
#   def setup
#     @file_path = Rails.root.join("tmp", "sigaa_data.json")
#     @data = [
#       {
#         "codigo" => "TURMA123",
#         "nome" => "Engenharia de Software",
#         "semestre" => "2023.2",
#         "participantes" => [
#           {
#             "nome" => "João Silva",
#             "email" => "joao@example.com",
#             "matricula" => "2023001",
#             "papel" => "discente"
#           }
#         ]
#       }
#     ]
#     File.write(@file_path, @data.to_json)
#   end

#   def teardown
#     File.delete(@file_path) if File.exist?(@file_path)
#   end

#   test "importa turmas e usuarios com sucesso" do
#     assert_difference "ActionMailer::Base.deliveries.size", 1 do
#       service = SigaaImportService.new(@file_path)
#       result = service.process

#       assert_empty result[:errors]
#       assert_equal 1, result[:turmas_created]
#       assert_equal 1, result[:usuarios_created]
#     end

#     turma = Turma.find_by(codigo: "TURMA123")
#     assert_not_nil turma
#     assert_equal "Engenharia de Software", turma.nome

#     user = User.find_by(matricula: "2023001")
#     assert_not_nil user
#     assert_equal "João Silva", user.nome
#     assert user.authenticate(user.password) if user.respond_to?(:authenticate) # Optional verification if has_secure_password

#     matricula = MatriculaTurma.find_by(turma: turma, user: user)
#     assert_not_nil matricula
#     assert_equal "discente", matricula.papel
#   end

#   test "reverte em caso de erro de validação" do
#     # Criar dados inválidos (semestre faltando para Turma)
#     invalid_data = @data.dup
#     invalid_data[0]["semestre"] = nil
#     File.write(@file_path, invalid_data.to_json)

#     service = SigaaImportService.new(@file_path)
#     result = service.process

#     assert_not_empty result[:errors]
#     assert_equal 0, Turma.count
#     assert_equal 0, User.count
#   end
# end
