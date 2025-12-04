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
      You are recommending karaoke songs.
      You are skilled at reading the mood, energy, and style of the currently selected songs and choosing the next best songs to sing.

      INPUT SONGS (do not recommend these):
      #{song_list.first(10).join("\n")}

      TASK:
      Recommend exactly 10 **different** songs that fit well with the mood and vibe of the input list.
      All recommended songs **must currently exist in either the JOYSOUND or DAM karaoke libraries**.
      Do **not** include any of the provided songs.

      OUTPUT FORMAT (follow this exactly):
      - Return **ONLY** a JSON array of 10 objects.
      - Each object must contain exactly:
          "name"   — the song title (string)
          "artist" — the performing artist (string)
      - No extra text, no commentary, no labels, and no code fences.

      If you cannot find 10 valid songs that meet the criteria, return a JSON array (possibly empty) with no explanation.
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
