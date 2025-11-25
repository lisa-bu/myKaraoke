class Song < ApplicationRecord
  has_many :playlists_songs, dependent: :destroy
  has_many :playlists, through: :playlists_songs
  has_many :difficulty_ratings, dependent: :destroy

  validates :name, presence: true
  validates :artist, presence: true, uniqueness: true
  validates :ISRC, presence: true, uniqueness: true
  validates :availability, presence: true

end
