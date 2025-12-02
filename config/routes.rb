Rails.application.routes.draw do
  devise_for :users
  root to: "pages#landing"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get 'search/index'
  get "/auth/spotify/callback", to: "spotify_auth#callback"
  get "/auth/failure",          to: "spotify_auth#failure"
  get "/home", to: "pages#home"
  # Defines the root path route ("/")
  # root "posts#index"
  resources :playlists, only: [:index, :show, :create, :update, :destroy] do
    collection do
      post :import_spotify_playlists
    end
    resources :playlist_songs, only: [:new, :create] do
      get :surprise, on: :collection
    end
  end

  resources :playlist_songs, only: [:destroy]

  resources :songs, only: [:show] do
    resources :difficulty_ratings, only: [:create]
    resource :favorite, only: [:create, :destroy]
  end

  resources :difficulty_ratings, only: [ :update]

  resources :friendships, only: [:create, :update, :destroy]

  resources :users, only: [:update] do
    member  do
      patch :stop_singing
    end
  end
end
