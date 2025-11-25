class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :playlists
  has_many :playlist_songs
  has_many :difficulty_ratings
  has_many :songs, through: :difficulty_ratings

  validates :name, presence: true, uniqueness: true, length: { minimum: 1, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Friendships (self-join)
  has_many :sent_friendships,
           class_name: "Friendship",
           foreign_key: "asker_id"

  has_many :received_friendships,
           class_name: "Friendship",
           foreign_key: "receiver_id"

           def friends
             asked_friends + received_friends
           end


end
