class CheckKaraokeAvailabilityJob < ApplicationJob
  queue_as :default

  def perform(song_id)
    song = Song.find_by(id: song_id)
    return unless song

    song.check_karaoke_availability!
  end
end
