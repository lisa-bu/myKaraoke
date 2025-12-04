class Song < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_name_and_artist,
    against: [:name, :artist],
    using: {
      tsearch: { prefix: true }
    }

  has_many :playlist_songs, dependent: :destroy
  has_many :playlists, through: :playlist_songs
  has_many :crowd_pleaser_playlist_songs, dependent: :destroy
  has_many :crowd_pleaser_playlists, through: :crowd_pleaser_playlist_songs
  has_many :difficulty_ratings, dependent: :destroy

  validates :name, presence: true
  validates :artist, presence: true
  validates :ISRC, presence: true, uniqueness: true
  acts_as_favoritable

  def karaoke_availability
    return {} unless availability.is_a?(Hash)

    availability.slice("dam", "joysound")
  end

  def available_on_dam?
    availability.is_a?(Hash) && availability.dig("dam", "available") == true
  end

  def available_on_joysound?
    availability.is_a?(Hash) && availability.dig("joysound", "available") == true
  end

  def check_karaoke_availability!
    service = KaraokeAvailabilityService.new
    result = service.check_availability(song_name: name, artist_name: artist)

    current_availability = availability.is_a?(Hash) ? availability : {}
    update!(availability: current_availability.merge(result.slice(:dam, :joysound).stringify_keys))
  end
end
