class DifficultyRating < ApplicationRecord
  belongs_to :user
  belongs_to :song

  validates :difficulty_level, presence: true, numericality: { only_integer: true, in: 1..10 }

end
