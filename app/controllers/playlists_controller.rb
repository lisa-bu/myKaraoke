class PlaylistsController < ApplicationController
  # before_action :set_playlist
  def index
    authorize Playlist
    @playlists = policy_scope(Playlist)
    @playlist = Playlist.new
  end

  def show
    @playlist = Playlist.find(params[:id])
    authorize @playlist
  end

  def new
    @playlist = Playlist.new
    authorize Playlist
  end

  def create
    @playlist = Playlist.new(playlist_params)
    authorize @playlist
    if @playlist.save
      redirect_to playlist_path(@playlist)
    else
      render :new, status: :unprocessable_entity
    end

  end

  def edit
    @playlist = Playlist.find(params[:id])
    authorize @playlist
  end

  def update
    @playlist = Playlist.find(params[:id])
    if @playlist.update(playlist_params)
      redirect_to playlist_path(@playlist)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @playlist = Playlist.find(params[:id])
    authorize @playlist
    unless @playlist.id == current_user.current_playlist_id
      @playlist.destroy
    else
      flash[:notice] = "Cannot delete your singing now playlist"
      @playlists = policy_scope(Playlist)
      @playlist = Playlist.new
    end
    redirect_to playlists_path
  end

  private

  def set_playlist
    @playlist = Playlist.find(params[:id])
  end

  def playlist_params
    params.require(:playlist).permit(:name)
  end
end
