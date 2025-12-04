class CrowdPleaserPlaylistsController < ApplicationController
  before_action :set_crowd_pleaser_playlist

  def show
    authorize @crowd_pleaser_playlist
    @playlist = current_user.playlists.find_by(id: current_user.current_playlist_id) || current_user.playlists.first
    @playlist_song = PlaylistSong.new
  end

  def add_to_session
    authorize @crowd_pleaser_playlist
    @playlist = current_user.playlists.find_by(id: current_user.current_playlist_id) || current_user.playlists.first

    songs_added = 0
    @crowd_pleaser_playlist.songs.each do |song|
      next if @playlist.songs.include?(song)

      position = @playlist.songs.empty? ? 0 : @playlist.songs.count + 1
      PlaylistSong.create!(playlist: @playlist, song: song, position: position)
      songs_added += 1
    end

    redirect_to home_path, notice: "#{songs_added} songs added to your session!"
  end

  private

  def set_crowd_pleaser_playlist
    @crowd_pleaser_playlist = CrowdPleaserPlaylist.find(params[:id])
  end
end
