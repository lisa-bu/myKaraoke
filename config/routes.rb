Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  resources :playlists, only: [:index, :show, :create, :update, :destroy] do
    resources :playlist_songs, only: [:new, :create]
  end

  resources :playlist_songs, only: [:destroy]

  resources :songs, only: [:show] do
    resources :difficulty_ratings, only: [:create]
  end

  resources :difficulty_ratings, only: [ :update]

  resources :friendships, only: [:create, :update, :destroy]
end
