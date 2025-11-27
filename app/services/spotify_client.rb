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

  def user_for(current_user)
    return nil unless current_user.spotify_access_token

    refresh_user_token_if_needed(current_user)

    RSpotify::User.new(
      "id" => current_user.spotify_uid,
      "credentials" => {
        "token"         => current_user.spotify_access_token,
        "refresh_token" => current_user.spotify_refresh_token,
        "expires_at"    => current_user.spotify_expires_at.to_i
      }
    )
  end

  # -----------------------------
  # Auto-refresh token when expired
  # -----------------------------
  def refresh_user_token_if_needed(user)
    return unless user.spotify_expires_at <= Time.current

    refreshed = RSpotify::User.refresh_token(user.spotify_refresh_token)

    user.update!(
      spotify_access_token: refreshed["access_token"],
      spotify_expires_at:   Time.current + refreshed["expires_in"].to_i.seconds
    )
  end

  # -----------------------------
  # Search Methods
  # -----------------------------

  # User specific example
  # spotify_user = SpotifyClient.instance.user_for(current_user)
  # @tracks = spotify_user.top_tracks(limit: 20)

  # General example
  # SpotifyClient.instance.search_tracks("Drake")
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
