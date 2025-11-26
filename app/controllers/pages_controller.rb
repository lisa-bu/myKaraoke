class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @current_playlist = current_user.playlists.find_by(id: current_user.current_playlist_id)

    if @current_playlist.nil?
      @current_playlist = current_user.playlists.create!( name: "Playlist #{current_user.playlists.count + 1}"
    )
    current_user.update!(current_playlist_id: @current_playlist.id)
    end
  end
end
