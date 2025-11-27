class PlaylistSongsController < ApplicationController
  before_action :set_playlist, only: [:destroy]

  def new
    @playlist_song = PlaylistSong.new

    authorize @playlist_song
  end

  def create
    @playlist_song = PlaylistSong.new(playlist_song_params)
    @playlist_song.playlist = @playlist

    if @playlist_song.save
      redirect_to @playlist, notice: "Song added!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
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
    params.require(:playlist_song).permit(:song_id, :position)
  end

end



# class PlaylistsSongsController < ApplicationController
#   before_action :set_playlist
#   before_action :set_playlist_song, only: [:destroy]

#   def create
#     @playlist_song = PlaylistsSong.new(playlist_song_params)
#     @playlist_song.playlist = @playlist

#     if @playlist_song.save
#       redirect_to @playlist, notice: "Song added!"
#     else
#       render :new, status: :unprocessable_entity
#     end
#   end

#   private

#   def set_playlist
#     @playlist = Playlist.find(params[:playlist_id])
#   end

#   def set_playlist_song
#     @playlist_song = PlaylistsSong.find(params[:id])
#   end

#   def playlist_song_params
#     params.require(:playlists_song).permit(:song_id, :position)
#   end
# end
