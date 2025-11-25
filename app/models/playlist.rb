class Playlist < ApplicationRecord
  belongs_to :user
  has_many :playlists_songs, dependent: :destroy
  has_many :songs, through: :playlists_songs

  validates :name, presence: true
  validates :user_id, presence: true
end
