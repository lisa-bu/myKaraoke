class LyricsController < ApplicationController
  skip_after_action :verify_authorized

  def show
    @song = Song.find(params[:song_id])
    @lyrics = GeniusClient.instance.lyrics_for(@song.name, @song.artist)

    respond_to do |format|
      format.turbo_stream
      format.html { render partial: "lyrics/modal", locals: { song: @song, lyrics: @lyrics } }
    end
  end
end
