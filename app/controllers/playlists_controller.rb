class PlaylistsController < ApplicationController
  before_action :set_playlist, only: [:show, :update, :destroy ]
  def index
  authorize Playlist
  @playlists = policy_scope(Playlist)
  @playlist = Playlist.new

  # SPOTIFY PLAYLISTS!
  @spotify_playlists = SpotifyClient.instance.user_playlists(current_user)

  return unless params[:query].present?

  query = params[:query].strip
  @playlists = @playlists.search_by_name(query)
  end

  def show
    # SPOTIFY PLAYLISTS FIRST — before anything else
    if params[:id].start_with?("spotify_")
      spotify_id = params[:id].sub("spotify_", "")

      user = SpotifyClient.instance.user_for(current_user)

      # Your RSpotify version requires: find(owner_id, playlist_id)
      @playlist = RSpotify::Playlist.find(user.id, spotify_id)
      @spotify_tracks = @playlist.tracks

      skip_authorization
      return
    end

    # LOCAL PLAYLISTS
    @playlist = Playlist.find(params[:id])
    authorize @playlist

    @songs = []

    if params[:query].present?
      query = params[:query].strip
      @songs = Song.search_by_name_and_artist(query)
    end
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
    if @playlist.update(playlist_params)
      redirect_to playlist_path(@playlist)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @playlist
    if @playlist.id == current_user.current_playlist_id
      flash[:notice] = "Cannot delete your singing now playlist"
      @playlists = policy_scope(Playlist)
      @playlist = Playlist.new
    else
      @playlist.destroy
    end

    redirect_to playlists_path
  end

  # # CURRENT USER SPOTIFY PLAYLISTS
  # def spotify
  #   @playlists = SpotifyClient.instance.user_playlists(current_user)
  # end

  private

  def set_playlist
  return if params[:id].start_with?("spotify_")

  @playlist = Playlist.find(params[:id])
  end

  def playlist_params
    params.require(:playlist).permit(:name)
  end

  def load_spotify_playlist
  spotify_id = params[:id].sub("spotify_", "")
  user = SpotifyClient.instance.user_for(current_user)

  @playlist = RSpotify::Playlist.find(current_user.spotify_uid, spotify_id)
  @spotify_tracks = @playlist.tracks

  render :show
  end
end
