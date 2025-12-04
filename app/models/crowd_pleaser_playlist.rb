class CrowdPleaserPlaylist < ApplicationRecord
  has_many :crowd_pleaser_playlist_songs, -> { order(:position) }, dependent: :destroy
  has_many :songs, through: :crowd_pleaser_playlist_songs

  validates :name, presence: true
end
