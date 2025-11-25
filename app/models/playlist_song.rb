class PlaylistSong < ApplicationRecord
  belongs_to :playlist
  belongs_to :song

  validates :position, presence: true

end
