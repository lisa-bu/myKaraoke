# app/services/spotify_client.rb
require "rspotify"
require "singleton"

class SpotifyClient
  include Singleton

  def initialize
    authenticate!
  end

  # -----------------------------
  # Authentication
  # -----------------------------
  def authenticate!
    RSpotify.authenticate(
      ENV.fetch("SPOTIFY_CLIENT_ID"),
      ENV.fetch("SPOTIFY_CLIENT_SECRET")
    )
  end

  # -----------------------------
  # Search Methods
  # -----------------------------
  def search_tracks(query, market: "US", limit: 10)
    RSpotify::Track.search(query, market: market, limit: limit)
  end

  def search_artists(query, limit: 10)
    RSpotify::Artist.search(query, limit: limit)
  end

  def search_albums(query, limit: 10)
    RSpotify::Album.search(query, limit: limit)
  end

  def search_playlists(query, limit: 10)
    RSpotify::Playlist.search(query, limit: limit)
  end
end
