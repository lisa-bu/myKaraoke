class PlaylistsController < ApplicationController
  before_action :set_playlist, only: [:show, :update, :destroy ]
  def index
    authorize Playlist
    @playlists = policy_scope(Playlist)
    @playlist = Playlist.new
  end

  def show
    authorize @playlist
  end

  def new
    @playlist = Playlist.new
    authorize Playlist
  end

  def create
    @playlist = Playlist.new(playlist_params)
    @playlist.user = current_user
    authorize @playlist
    if @playlist.save
      redirect_to playlist_path(@playlist)
    else
      @playlists = policy_scope(Playlist)
      render :index, status: :unprocessable_entity
    end

  end

  def update
    if @playlist.update(playlist_params)
      redirect_to playlist_path(@playlist)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
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
