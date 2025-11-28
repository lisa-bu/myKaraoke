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
  "Drake",
  "The Weeknd",
  "Bad Bunny",
  "Billie Eilish",
  "Ariana Grande",
  "Justin Bieber",
  "Dua Lipa",
  "Olivia Rodrigo",
  "Post Malone",
  "Travis Scott",
  "SZA",
  "Doja Cat",
  "Ed Sheeran",
  "Kendrick Lamar",
  "Metro Boomin",
  "Future",
  "J Balvin",
  "Karol G",
  "Rosalía",
  "BTS",
  "NewJeans",
  "The Kid LAROI",
  "Jung Kook",
  "Harry Styles"
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
      song.availability = "n/a"
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

puts "Finished!"
