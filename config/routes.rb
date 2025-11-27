Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  # --- Spotify OAuth Routes ---
  get "/auth/spotify",          to: "spotify_auth#login",    as: :spotify_login
  get "/auth/spotify/callback", to: "spotify_auth#callback"
  get "/spotify/token",         to: "spotify_auth#token"
  # ----------------------------

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

   # --- Playlist Routes ---
  resources :playlists, only: [:index, :show, :create, :update, :destroy] do
    resources :playlist_songs, only: [:new, :create]
  end

  resources :playlist_songs, only: [:destroy]
  # -------------------------

  # --- Songs & Difficulty Ratings ---
  resources :songs, only: [:show] do
    resources :difficulty_ratings, only: [:create]
    resource :favorite, only: [:create, :destroy]
  end

  resources :difficulty_ratings, only: [ :update]

  resources :friendships, only: [:create, :update, :destroy]
   # ---------------------------------

  # --- Update user's current playlist ---
  resources :users, only: [:update] do
    member  do
      patch :stop_singing
    end
  end
  # ---------------------------------
end
