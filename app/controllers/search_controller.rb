class SearchController < ApplicationController
  def index
    query = params[:q]

    if query.blank?
      render json: []
      return
    end

    tracks = RSpotify::Track.search(query)

    render json: tracks.map { |t|
      {
        name: t.name,
        artist: t.artists.map(&:name).join(", "),
        preview_url: t.preview_url,
        image: t.album.images.first&.dig("url")
      }
    }
  end
end
