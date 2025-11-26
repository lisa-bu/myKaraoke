require "rspotify"

puts ">>> RSpotify initializer loaded!"

RSpotify::authenticate(
  ENV["SPOTIFY_CLIENT_ID"],
  ENV["SPOTIFY_CLIENT_SECRET"]
)
