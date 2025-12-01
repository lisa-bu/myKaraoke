class UsersController < ApplicationController
  def update
    @user = User.find(params[:id])
    authorize @user
    @playlist = @user.playlists.find(params[:current_playlist_id])
    if @user.update(current_playlist_id: @playlist.id)
      redirect_to home_path
    else
      redirect_to playlists_path, alert: "Failed to set current playlist"
    end
  end

  def stop_singing
    @user = User.find(params[:id])
    authorize @user
    @user.update(current_playlist_id: nil)
    redirect_to home_path
  end

end
