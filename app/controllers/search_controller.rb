class SearchController < ApplicationController
  def index
    return unless params[:q].present?

    @tracks = RSpotify::Track.search(params[:q])
  end
end
