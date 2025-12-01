class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_favoritable

  def create
    if current_user.favorite(@favoritable)
      redirect_to @favoritable, notice: "#{@favoritable.class.name} added to favorites!"
    else
      redirect_to @favoritable, alert: 'Unable to add to favorites'
    end
  end

  def destroy
    current_user.unfavorite(@favoritable)
    redirect_to home_path
  end

  private
  def set_favoritable
    if params[:song_id]
      @favoritable = Song.find(params[:song_id])
    elsif params[:playlist_id]
      @favoritable = Playlist.find(params[:playlist_id])
    else
      redirect_to home_path
    end
  end
end
