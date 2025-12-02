class GetRecommendations
  def initialize(playlist_songs)
    @playlist_songs = playlist_songs
  end

  def call
    song_list = []
    @playlist_songs.each do |playlist_song|
      next if playlist_song.song.nil?
      song_list << "#{playlist_song.song.name} by #{playlist_song.song.artist}"
    end
    return [] if song_list.empty?

    prompt = <<~PROMPT
    Based on the following songs (up to 10):
    #{song_list.first(10).join("\n")}

    Recommend 10 **different** songs that would be good choices to sing at karaoke.
    Do **not** include any of the provided songs in your recommendations.

    Return the result as **ONLY** a JSON array of 10 objects.
    Each object must contain exactly:
      - "name": the song title
      - "artist": the performing artist

    Return no extra text, no explanations, no code fencing.
    PROMPT

    chat = RubyLLM.chat
    response = chat.ask(prompt)


    recommendations = JSON.parse(response.content)

    SpotifyClient.instance

    songs = []

    recommendations.each do |rec|
      tracks = RSpotify::Track.search("#{rec['name']} #{rec['artist']}", limit: 2)
      next if tracks.nil?
      tracks.flatten.each do |track|
        created_song = Song.find_or_create_by!(ISRC: track.external_ids["isrc"]) do |song|
            song.name = track.name
            song.artist = track.artists.first.name
            song.difficulty_average = 0.0
            song.image_url = track.album.images.first["url"]
            song.ISRC =  track.external_ids["isrc"]
            song.spotify_id = track.id
            song.availability = "n/a"
        end

        songs << created_song
      end
    end
    songs.uniq
  end
end
