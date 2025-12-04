class LyricsController < ApplicationController
  skip_after_action :verify_authorized

  def show
    @song = Song.find(params[:song_id])
    # Only use hardcoded lyrics - Genius API disabled for demo
    @lyrics = @song.lyrics

    respond_to do |format|
      format.turbo_stream
      format.html { render partial: "lyrics/modal", locals: { song: @song, lyrics: @lyrics } }
    end
  end
end
