class PlaylistsController < ApplicationController
  def index
    @playlists = Playlist.all
    # authorize @playlists
  end

  def show
    # authorize @playlists
    @playlist = Playlist.find(params[:id])
  end

  def create
    @playlist = current_user.playlists.Playlist.new(playlist_params)
    if @playlist.save
      redirect_to list_path(@playlist)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @playlist = Playlist.find(params[:id])
    if @restaurant.update(restaurant_params)
      redirect_to restaurant_path(@restaurant)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # authorize @playlist
    @playlist = Playlist.find(params[:id])
    @playlist.destroy
    redirect_to playlists_path
  end

  private

  def playlist_params
    params.require(:playlist).permit(:name)
  end
end
