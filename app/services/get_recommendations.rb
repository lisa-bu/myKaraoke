class GetRecommendations
  MAX_SEEDS = 5

  def initialize(playlist_songs)
    @playlist_songs = playlist_songs
  end

  def call
    names = @playlist_songs.filter_map { |ps| ps.song&.artist }.uniq
    return [] if names.empty?

    SpotifyClient.instance

    ids = []
    names.first(MAX_SEEDS).each do |name|
      results = RSpotify::Artist.search(name, limit: 1)
      artist = results.first
      ids << artist.id if artist
    end
    return [] if ids.empty?

   tracks = []
  begin
    tracks = RSpotify::Recommendations.generate(limit: 20, seed_artists: ids).tracks
  rescue RestClient::NotFound => e
    Rails.logger.warn("Spotify recommendations not found for seeds #{ids.inspect}: #{e.message}")
    return []
  end

    songs = tracks.map do |track|
      song = Song.find_or_initialize_by(spotify_id: track.id)
      song.name = track.name
      song.artist = track.artists.first&.name
      song.image_url = track.album&.images&.first&.dig("url")
      song.isrc = track.external_ids&.dig("isrc")
      song.save
      song
    end

    songs
  end
end
