Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Error pages
  get "404", to: "errors#not_found", as: :not_found_error
  get "500", to: "errors#internal_server_error", as: :internal_server_error

  # Authentication
  resource :session, only: [:create, :destroy]
  get '/login', to: 'sessions#new', as: :login
  resources :registrations, only: [:new, :create]

  # Settings
  resource :settings, only: [:show, :update]

  # Home
  root to: "home#index"

  # Events
  resources :events, only: [:index, :new]

  # Contacts
  resources :contacts, only: [:index, :new]

  # Catch all undefined routes
  match "*path", to: "errors#not_found", via: :all
end
