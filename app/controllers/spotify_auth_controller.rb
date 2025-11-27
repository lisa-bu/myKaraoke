class SpotifyAuthController < ApplicationController
  def callback
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
# Come back later
    raise
    redirect_to root_path
  end
end
