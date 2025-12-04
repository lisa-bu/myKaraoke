class PagesController < ApplicationController
   skip_before_action :authenticate_user!, only: [ :landing ]

  def home
    @current_playlist = current_user.playlists.find_by(id: current_user.current_playlist_id)

    if @current_playlist.nil?
      @current_playlist = current_user.playlists.create!(name: "Playlist #{current_user.playlists.count + 1}")
      current_user.update!(current_playlist_id: @current_playlist.id)
    end

    # Find last used playlist (other than current) that has songs
    @last_playlist = current_user.playlists
      .where.not(id: @current_playlist.id)
      .joins(:playlist_songs)
      .distinct
      .order(updated_at: :desc)
      .first
  end
  def landing

  end
end
