class DifficultyRatingsController < ApplicationController
  before_action :set_song, only: [:create]
  before_action :set_difficulty_rating, only: [:update]

  def create
    @difficulty_rating = DifficultyRating.find_or_initialize_by(user: current_user,song: @song)
    @difficulty_rating.difficulty_level = params[:difficulty_level]

    if @difficulty_rating.save
      update_song_average(@song)
      redirect_to @song, notice: "Difficulty rating saved"
    else
      redirect_to @song, status: :unprocessable_entity
    end
  end

  def update
    if @difficulty_rating.update(difficulty_level: params[:difficulty_level])
      update_song_average(@difficulty_rating.song)
      redirect_to @difficulty_rating.song, notice: "Rating updated"
    else
      redirect_to @difficulty_rating.song, status: :unprocessable_entity
    end
  end

  private

  def set_song
    @song = Song.find(params[:song_id])
  end

  def set_difficulty_rating
    @difficulty_rating = DifficultyRating.find(params[:id])
  end

  def update_song_average(song)
    avg = song.difficulty_ratings.average(:difficulty_level)
    song.update(difficulty_average: avg || 0.0)
  end
end
