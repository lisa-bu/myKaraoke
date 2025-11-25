class PlaylistsController < ApplicationController
  def index
  end

  def show
    authorize @playlist
  end

  def create
    authorize @playlist
  end

  def update
    authorize @playlist
  end

  def destroy
    authorize @playlist
  end
end
