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

  def refresh_user_token_if_needed(user)
    return unless user.spotify_expires_at <= Time.current

    refreshed = RSpotify::User.refresh_token(user.spotify_refresh_token)

    user.update!(
      spotify_access_token: refreshed["access_token"],
      spotify_expires_at:   Time.current + refreshed["expires_in"].to_i.seconds
    )
  end

  def user_for(current_user)
    return nil unless current_user.spotify_access_token

    RSpotify::User.new(
      "id" => current_user.spotify_uid,
      "credentials" => {
        "token"         => current_user.spotify_access_token,
        "refresh_token" => current_user.spotify_refresh_token,
        "expires_at"    => current_user.spotify_expires_at.to_i,
        "access_refresh_callback" => proc { |new_token, expires_in|
          current_user.update!(
            spotify_access_token: new_token,
            spotify_expires_at: Time.current + expires_in.to_i.seconds
          )
        }
      }
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
  def search_tracks(query, market: "US", limit: 50)
    RSpotify::Track.search(query, market: market, limit: limit)
  end

  def search_artists(query, limit: 10)
    RSpotify::Artist.search(query, limit: limit)
  end

  def search_albums(query, limit: 10)
    RSpotify::Album.search(query, limit: limit)
  end

  # Need to test lol
  def search_playlists(query, limit: 10)
    RSpotify::Playlist.search(query, limit: limit)
  end

  # -----------------------------
  # User Playlist Methods
  # -----------------------------

  # Fetch all playlists for the authenticated user (public and private)
  def user_playlists(current_user, limit: 50)
    spotify_user = user_for(current_user)
    return [] unless spotify_user

    spotify_user.playlists(limit: limit)
  end

  # Fetch tracks from a specific Spotify playlist
  def playlist_tracks(playlist_id, current_user, limit: 100)
    spotify_user = user_for(current_user)
    return [] unless spotify_user

    playlist = RSpotify::Playlist.find_by_id(playlist_id)
    return [] unless playlist

    playlist.tracks(limit: limit)
  end
end
