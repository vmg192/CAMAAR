# config/routes.rb
Rails.application.routes.draw do
  # ... outras rotas
  
  resources :formularios, only: [] do
    resources :respostas, only: [:index, :new, :create]
  end
  
  get 'respostas', to: 'respostas#index'
end