class PlaylistsController < ApplicationController
  before_action :set_playlist, only: [:show, :update, :destroy ]
  def index
    authorize Playlist
    @playlists = policy_scope(Playlist)
    @playlist = Playlist.new

    return unless params[:query].present?

    # query   = params[:query].strip
    # pattern = "%#{query}%"
    # @playlists = Playlist.where("name ILIKE ?", pattern)
    query = params[:query].strip
    @playlists = @playlists.search_by_name(query)
  end

  def show
    @playlist = Playlist.find(params[:id])
    @songs = []
    authorize @playlist

    return unless params[:query].present?

    # query   = params[:query].strip
    # pattern = "%#{query}%"
    # @songs = Song.where("name ILIKE ? OR artist ILIKE ?", pattern, pattern)
    query = params[:query].strip
    @songs = Song.search_by_name_and_artist(query)
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
    @playlist = Playlist.find(params[:id])
    authorize @playlist
    if @playlist.update(playlist_params)
      redirect_to playlist_path(@playlist)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @playlist
    User.where(current_playlist_id: @playlist.id).update_all(current_playlist_id: nil)
    @playlist.destroy
    redirect_to playlists_path, notice: "Playlist deleted."
  end

  private

  def set_playlist
    @playlist = Playlist.find(params[:id])
  end

  def playlist_params
    params.require(:playlist).permit(:name)
  end
end
