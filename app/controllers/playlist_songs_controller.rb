class PlaylistSongsController < ApplicationController
  before_action :set_playlist, only: [:new, :create]
  before_action :set_playlist_song, only: [:destroy]

  def surprise
    @playlist = Playlist.find(params[:playlist_id])
    authorize PlaylistSong

    @song = Song.order("RANDOM()").first
  end

  def new
    @playlist_song = PlaylistSong.new
    authorize PlaylistSong
    @spotify_songs_1 = Song.all.shuffle.take(10)
    @spotify_songs_2 = Song.all.shuffle.take(10)

    @my_karaoke_recs = GetRecommendations.new(@playlist.playlist_songs).call
  end

  def create
    @playlist_song = PlaylistSong.new(playlist_song_params)
    @playlist_song.position = 0
    @playlist_song.playlist = @playlist
    @playlist_song.song_id = params[:playlist_song][:song_id]
    authorize @playlist_song

    unless @playlist.songs.empty?
      @playlist_song.position = @playlist.songs.count + 1
    end

    if @playlist_song.save
      if current_user.current_playlist_id == @playlist.id
        # raise
        redirect_to home_path, notice: "Song added!"
      else
        redirect_to playlist_path(@playlist), notice: "Song added!"
      end
    else
      @songs = Song.all
      render :new, status: :unprocessable_entity
      # redirect_to playlist_path(@playlist), alert: "Failed to add song."
    end
  end
# plyalistid position
  def destroy
    @playlist = @playlist_song.playlist
    authorize @playlist_song

    @playlist_song.destroy

    respond_to do |format|
      format.turbo_stream { head :ok }
      format.html { redirect_to @playlist, notice: "Song removed!" }
    end
  end

  private

  def set_playlist
    @playlist = Playlist.find(params[:playlist_id])
  end

  def set_playlist_song
    @playlist_song = PlaylistSong.find(params[:id])
  end

  def playlist_song_params
    params.require(:playlist_song).permit(:position, :song_id, :playlist_id)
  end
end
