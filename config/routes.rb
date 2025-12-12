Rails.application.routes.draw do
  # --- ROTAS DE AVALIACOES ---
  resources :avaliacoes, only: [ :index, :create ] do
    collection do
      get :gestao_envios
    end
    member do
      get :resultados
    end
    # Rotas para alunos responderem avaliações (Feature 99)
    resources :respostas, only: [ :new, :create ]
  end

  # --- ROTAS DE IMPORTAÇÃO SIGAA ---
  resources :sigaa_imports, only: [ :new, :create ] do
    collection do
      post :update  # For update/sync operations
      get :success  # For showing import results
    end
  end

  # --- ROTAS DE GERENCIAMENTO DE MODELOS ---
  resources :modelos do
    member do
      post :clone
    end
  end

  resource :session
  resources :passwords, param: :token
  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # --- ROTAS DO INTEGRANTE 4 (RESPOSTAS) ---
  # Define as rotas aninhadas para criar respostas dentro de um formulário
  resources :formularios, only: [] do
    resources :respostas, only: [ :index, :new, :create ]
  end

  # Rota solta para a listagem geral de respostas (dashboard do aluno)
  get "respostas", to: "respostas#index"
  # -----------------------------------------

  # Defines the root path route ("/")
  root "pages#index"

  get "home" => "home#index"
end
