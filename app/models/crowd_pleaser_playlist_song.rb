class CrowdPleaserPlaylistSong < ApplicationRecord
  belongs_to :crowd_pleaser_playlist
  belongs_to :song

  validates :position, presence: true
end
