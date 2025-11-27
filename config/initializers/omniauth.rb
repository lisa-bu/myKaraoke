require 'rspotify/oauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify,
  ENV["SPOTIFY_CLIENT_ID"],
  ENV["SPOTIFY_CLIENT_SECRET"],
  scope: "user-read-email user-read-private playlist-read-private playlist-read-collaborative user-top-read user-read-recently-played"
end

OmniAuth.config.allowed_request_methods = [:post, :get]
