class SpotifyAuthController < ApplicationController
  require "net/http"
  require "uri"
  require "json"

  # ----- Redirect the user to Spotify for login / consent -----
  def login
    scope = %w[
      streaming
      user-read-email
      user-read-private
      user-read-playback-state
      user-modify-playback-state
    ].join(" ")

    query = {
      client_id: ENV["SPOTIFY_CLIENT_ID"],
      response_type: "code",
      redirect_uri: ENV["SPOTIFY_REDIRECT_URI"],
      scope: scope
    }.to_query

    redirect_to "https://accounts.spotify.com/authorize?#{query}", allow_other_host: true
  end
  # ------------------------------------------------------------

  # ------- Spotify calls this with ?code=... --------
  def callback
    if params[:error]
      redirect_to root_path, alert: "Spotify error: #{params[:error]}" and return
    end

    code = params[:code]
    uri  = URI("https://accounts.spotify.com/api/token")

    res = Net::HTTP.post_form(uri, {
      grant_type: "authorization_code",
      code: code,
      redirect_uri: ENV["SPOTIFY_REDIRECT_URI"],
      client_id: ENV["SPOTIFY_CLIENT_ID"],
      client_secret: ENV["SPOTIFY_CLIENT_SECRET"]
    })

    body = JSON.parse(res.body)

    if res.is_a?(Net::HTTPSuccess)
      session[:spotify_access_token]  = body["access_token"]
      session[:spotify_refresh_token] = body["refresh_token"]
      session[:spotify_expires_at]    = Time.now.to_i + body["expires_in"].to_i

      redirect_to root_path, notice: "Spotify connected!"
    else
      Rails.logger.error("Spotify token error: #{body}")
      redirect_to root_path, alert: "Could not connect to Spotify"
    end
  end
  # ---------------------------------------------------

  # ------ Called by front-end JS to get a valid access token -------
  def token
    refresh_access_token_if_needed

    if session[:spotify_access_token].present?
      render json: { access_token: session[:spotify_access_token] }
    else
      render json: { error: "not_authenticated" }, status: :unauthorized
    end
  end

  private

  def refresh_access_token_if_needed
    return unless session[:spotify_refresh_token].present?
    return unless session[:spotify_expires_at].present?

    # refresh 60 seconds before expiry
    if Time.now.to_i > session[:spotify_expires_at].to_i - 60
      uri = URI("https://accounts.spotify.com/api/token")

      res = Net::HTTP.post_form(uri, {
        grant_type:    "refresh_token",
        refresh_token: session[:spotify_refresh_token],
        client_id:     ENV["SPOTIFY_CLIENT_ID"],
        client_secret: ENV["SPOTIFY_CLIENT_SECRET"]
      })

      body = JSON.parse(res.body)

      if res.is_a?(Net::HTTPSuccess)
        session[:spotify_access_token] = body["access_token"]
        session[:spotify_expires_at]   = Time.now.to_i + body["expires_in"].to_i
      else
        Rails.logger.error("Spotify refresh error: #{body}")
        session[:spotify_access_token]  = nil
        session[:spotify_refresh_token] = nil
        session[:spotify_expires_at]    = nil
      end
    end
  end
  # ------------------------------------------------------------
end
