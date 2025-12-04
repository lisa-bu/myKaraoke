# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Cleaning database..."

User.update_all(current_playlist_id: nil)

PlaylistSong.destroy_all
DifficultyRating.destroy_all
Friendship.destroy_all

Playlist.destroy_all
Song.destroy_all

User.destroy_all


puts 'Creating users...'

alesya = User.create!(name:'alesya' ,email:"alesya@email.com", password: "123456!")
matt   = User.create!(name:'matt', email:"matt@email.com", password: "123456!")
tan    = User.create!(name:'tan', email:"tan@email.com", password: "123456!")
haris  = User.create!(name:'haris', email:"haris@email.com", password: "123456!")

users = [alesya, matt, tan, haris]
puts "Created #{users.count} users"


puts "Fetching songs from Spotify API..."

artists = [
  "Taylor Swift",
  "The Weeknd",
  "Billie Eilish",
  "Ariana Grande",
  "Justin Bieber",
  "Dua Lipa",
  "Olivia Rodrigo",
  "Post Malone",
  "Ed Sheeran",
  "Harry Styles",
  "Adele",
  "Bruno Mars",
  "Lady Gaga",
  "Beyoncé",
  "Katy Perry",
  "Rihanna",
  "Miley Cyrus",
  "Queen",
  "Journey",
  "ABBA",
  "Whitney Houston",
  "Bon Jovi",
  "Backstreet Boys",
  "Kelly Clarkson",
  "TWICE",
  "BTS",
  "Sam Smith",
  "Britney Spears",
  "The Killers",
  "Smash Mouth",
  "Weezer",
  "Linkin Park"
]

tracks = artists.map do |artist|
  puts artist
  SpotifyClient.instance.search_tracks(artist)
end

tracks.flatten.each do |track|
  puts track.name
  Song.find_or_create_by!(ISRC: track.external_ids["isrc"]) do |song|
      song.name = track.name
      song.artist = track.artists.first.name
      song.difficulty_average = 0.0
      song.image_url = track.album.images.first["url"]
      song.ISRC =  track.external_ids["isrc"]
      song.spotify_id = track.id
      song.availability = {}
  end
end

songs = Song.all

# create playlist
puts "Creating playlists..."

playlists = users.map do |user|
  Playlist.create!(
    name: "#{user.email.split('@').first.capitalize}'s playlist",
    user: user
  )
end

# fill playlists
puts "Adding songs to playlists..."

playlists.each do |playlist|
  songs.sample([10, songs.count].min).each_with_index do |song, index|
    PlaylistSong.create!(
      playlist: playlist,
      song: song,
      position: index + 1
    )
  end
end

# friendship
puts "Creating friendships..."

Friendship.create!(asker: alesya, receiver: matt)
Friendship.create!(asker: matt, receiver: tan)
Friendship.create!(asker: tan, receiver: haris)
Friendship.create!(asker: haris, receiver: alesya)

# difficulty rating
puts "Creating difficulty ratings..."

users.each do |user|
  songs.sample([5, songs.count].min).each do |song|
    DifficultyRating.create!(
      user: user,
      song: song,
      difficulty_level: rand(1..5)
    )
  end
end

songs.each do |song|
  avg = song.difficulty_ratings.average(:difficulty_level)
  song.update!(difficulty_average: avg || 0.0)
end

# Add mock karaoke availability data
puts "Adding karaoke availability data..."

songs.each_with_index do |song, index|
  availability = case index % 10
  when 0, 1, 2
    { "dam" => { "available" => true }, "joysound" => { "available" => true } }
  when 3, 4, 5
    { "dam" => { "available" => true }, "joysound" => { "available" => false } }
  when 6, 7, 8
    { "dam" => { "available" => false }, "joysound" => { "available" => true } }
  else
    { "dam" => { "available" => false }, "joysound" => { "available" => false } }
  end
  song.update!(availability: availability)
end

# Create crowd-pleaser playlists
puts "Creating crowd-pleaser playlists..."

CrowdPleaserPlaylistSong.destroy_all
CrowdPleaserPlaylist.destroy_all

crowd_pleaser_data = {
  "Party Anthems" => [
    { name: "Party in the U.S.A.", artist: "Miley Cyrus" },
    { name: "Wannabe", artist: "Spice Girls" },
    { name: "I Wanna Dance with Somebody", artist: "Whitney Houston" },
    { name: "We Found Love", artist: "Rihanna" },
    { name: "Uptown Funk", artist: "Mark Ronson" },
    { name: "Blinding Lights", artist: "The Weeknd" },
    { name: "Hey Ya!", artist: "Outkast" },
    { name: "Firework", artist: "Katy Perry" },
    { name: "Tik Tok", artist: "Kesha" },
    { name: "Can't Stop the Feeling!", artist: "Justin Timberlake" }
  ],
  "Power Ballads" => [
    { name: "I Will Always Love You", artist: "Whitney Houston" },
    { name: "Total Eclipse of the Heart", artist: "Bonnie Tyler" },
    { name: "My Heart Will Go On", artist: "Celine Dion" },
    { name: "I Don't Want to Miss a Thing", artist: "Aerosmith" },
    { name: "Nothing Compares 2 U", artist: "Sinead O'Connor" },
    { name: "All By Myself", artist: "Celine Dion" },
    { name: "Purple Rain", artist: "Prince" },
    { name: "Against All Odds", artist: "Phil Collins" },
    { name: "Careless Whisper", artist: "George Michael" },
    { name: "Hero", artist: "Mariah Carey" }
  ],
  "90s Hits" => [
    { name: "Baby One More Time", artist: "Britney Spears" },
    { name: "I Want It That Way", artist: "Backstreet Boys" },
    { name: "No Scrubs", artist: "TLC" },
    { name: "Waterfalls", artist: "TLC" },
    { name: "Creep", artist: "TLC" },
    { name: "MMMBop", artist: "Hanson" },
    { name: "Torn", artist: "Natalie Imbruglia" },
    { name: "Iris", artist: "Goo Goo Dolls" },
    { name: "Wonderwall", artist: "Oasis" },
    { name: "Smells Like Teen Spirit", artist: "Nirvana" }
  ],
  "Golden Hits" => [
    { name: "Hey Jude", artist: "The Beatles" },
    { name: "Let It Be", artist: "The Beatles" },
    { name: "Stand by Me", artist: "Ben E. King" },
    { name: "My Girl", artist: "The Temptations" },
    { name: "(You Make Me Feel Like) A Natural Woman", artist: "Aretha Franklin" },
    { name: "I Heard It Through the Grapevine", artist: "Marvin Gaye" },
    { name: "Can't Help Falling in Love", artist: "Elvis Presley" },
    { name: "Twist and Shout", artist: "The Beatles" },
    { name: "Respect", artist: "Aretha Franklin" },
    { name: "What a Wonderful World", artist: "Louis Armstrong" }
  ],
  "Alternative" => [
    { name: "Smells Like Teen Spirit", artist: "Nirvana" },
    { name: "Mr. Brightside", artist: "The Killers" },
    { name: "Seven Nation Army", artist: "The White Stripes" },
    { name: "Creep", artist: "Radiohead" },
    { name: "Zombie", artist: "The Cranberries" },
    { name: "Don't Look Back in Anger", artist: "Oasis" },
    { name: "Sugar, We're Goin Down", artist: "Fall Out Boy" },
    { name: "Welcome to the Black Parade", artist: "My Chemical Romance" },
    { name: "Californication", artist: "Red Hot Chili Peppers" },
    { name: "In the End", artist: "Linkin Park" }
  ],
  "Hip-Hop" => [
    { name: "Hotline Bling", artist: "Drake" },
    { name: "Yeah!", artist: "Usher" },
    { name: "Empire State of Mind", artist: "Jay-Z" },
    { name: "No Scrubs", artist: "TLC" },
    { name: "Crazy in Love", artist: "Beyoncé" },
    { name: "Super Bass", artist: "Nicki Minaj" },
    { name: "Lose Yourself", artist: "Eminem" },
    { name: "Gold Digger", artist: "Kanye West" },
    { name: "Say My Name", artist: "Destiny's Child" },
    { name: "Kiss Me More", artist: "Doja Cat" }
  ]
}

crowd_pleaser_data.each do |playlist_name, songs_data|
  playlist = CrowdPleaserPlaylist.create!(
    name: playlist_name,
    description: "A collection of #{playlist_name.downcase}"
  )

  songs_data.each_with_index do |song_data, index|
    # Search for the song via Spotify
    tracks = SpotifyClient.instance.search_tracks("#{song_data[:name]} #{song_data[:artist]}")
    track = tracks.first

    if track
      song = Song.find_or_create_by!(ISRC: track.external_ids["isrc"]) do |s|
        s.name = track.name
        s.artist = track.artists.first.name
        s.difficulty_average = 0.0
        s.image_url = track.album.images.first["url"]
        s.spotify_id = track.id
        s.availability = { "dam" => { "available" => true }, "joysound" => { "available" => true } }
      end

      # Ensure crowd pleaser songs are available on both DAM and JOYSOUND
      unless song.availability.dig("dam", "available") && song.availability.dig("joysound", "available")
        song.update!(availability: { "dam" => { "available" => true }, "joysound" => { "available" => true } })
      end

      CrowdPleaserPlaylistSong.create!(
        crowd_pleaser_playlist: playlist,
        song: song,
        position: index + 1
      )
      puts "  Added: #{song.name} - #{song.artist}"
    else
      puts "  Could not find: #{song_data[:name]} by #{song_data[:artist]}"
    end
  end

  puts "Created playlist: #{playlist_name} with #{playlist.songs.count} songs"
end

puts "Finished!"
