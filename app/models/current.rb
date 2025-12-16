# Armazena atributos da requisição atual (sessão, usuário)
class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true
end
