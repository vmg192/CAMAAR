# features/step_definitions/sistema_login_steps.rb

# NOTA: Before hook removido - dados de teste agora em features/support/test_data.rb


Dado('que os campos de login nao estao preenchidos') do
  visit new_session_path
  fill_in "email_address", with: ""
  fill_in "password", with: ""
end
