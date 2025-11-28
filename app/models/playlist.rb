class Playlist < ApplicationRecord
  # include PgSearch::Model

  include PgSearch::Model

  pg_search_scope :search_by_name,
    against: :name,
    using: {
      tsearch: { prefix: true }
    }

  belongs_to :user
  has_many :playlist_songs, dependent: :destroy
  has_many :songs, through: :playlist_songs

  validates :name, presence: true
  validates :user_id, presence: true
  acts_as_favoritable
end
