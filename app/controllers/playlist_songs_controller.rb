class PlaylistSongsController < ApplicationController
  before_action :set_playlist, only: [:new, :create]
  before_action :set_playlist_song, only: [:destroy]

  def surprise
    @playlist = Playlist.find(params[:playlist_id])
    authorize PlaylistSong

    @song = Song.order("RANDOM()").first

    render partial: "playlist_songs/surprise_me",
      locals: { playlist: @playlist, song: @song }
  end

  def new
    @playlist_song = PlaylistSong.new
    authorize PlaylistSong
    @songs = Song.all
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
        redirect_to root_path, notice: "Song added!"
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
    authorize @playlist_song

    @playlist_song.destroy
    redirect_to @playlist, notice: "Song removed!"
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
