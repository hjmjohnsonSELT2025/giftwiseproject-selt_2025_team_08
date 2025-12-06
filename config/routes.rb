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
  post "/quick_gift_ideas", to: "home#generate_quick_gift_idea", as: :quick_gift_ideas

  # Events
  resources :events, only: [:index, :new, :create, :edit, :update, :show, :destroy] do
    resources :recipients, only: [:create]
    resources :attendees, only: [:create, :destroy], controller: 'event_attendees'
    resources :discussions, only: [] do
      collection do
        get :show
        get :messages_feed
        post :create_message
      end
    end
  end

  # Recipients
  resources :recipients, only: [:destroy] do
    member do
      get :data
      post :generate_ideas
      post :gift_ideas
      post :gifts_for_recipients
    end
  end

  # Gift Ideas
  resources :gift_ideas, only: [:show, :update]
  resources :gifts_for_recipients, only: [:update]
  resources :contacts, only: [:index, :new, :create, :destroy] do
    collection do
      get :search
    end
    member do
      get :edit_note
      patch :update_note
    end
  end

  # Catch all undefined routes
  match "*path", to: "errors#not_found", via: :all
end
