class Song < ApplicationRecord
  has_many :playlist_songs, dependent: :destroy
  has_many :playlists, through: :playlist_songs
  has_many :difficulty_ratings, dependent: :destroy

  validates :name, presence: true
  validates :artist, presence: true
  validates :ISRC, presence: true, uniqueness: true
  validates :availability, presence: true
  acts_as_favoritable
end
