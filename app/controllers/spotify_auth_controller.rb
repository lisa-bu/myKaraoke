class SpotifyAuthController < ApplicationController
  def callback
    auth = request.env["omniauth.auth"]

    current_user.update!(
      spotify_uid:          auth.uid,
      spotify_access_token: auth.credentials.token,
      spotify_refresh_token: auth.credentials.refresh_token,
      spotify_expires_at:   Time.at(auth.credentials.expires_at)
    )

    redirect_to home_path, notice: "Spotify connected!"
  end

  def failure
    redirect_to home_path, alert: "Spotify authentication failed."
  end
end
