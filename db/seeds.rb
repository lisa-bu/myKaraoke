# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require "open-uri"
require "json"
require "faker"

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


puts "Fetching songs from Manana Karaoke API..."

song_titles = ["love", "missing", "summer", "winter", "dream"]

songs = song_titles.map do |song|
  url = "https://api.manana.kr/karaoke/song/#{song}.json"
  data = JSON.parse(URI.open(url).read)
  data
end

english_songs = songs.flatten.select do |song|
  title = song["title"]
  singer = song["singer"]
  isrc = song["no"]
  brand = song["brand"]

  title.is_a?(String) && singer.is_a?(String) &&
    isrc.present? && brand.present? &&
    title.match?(/\A[\p{Alnum}\p{Space}\p{Punct}]+\z/) &&
    singer.match?(/\A[\p{Alnum}\p{Space}\p{Punct}]+\z/)
end

songs = english_songs.shuffle.take(1000).map do |song_data|
  Song.find_or_create_by!(ISRC: song_data["no"]) do |song|
    song.name = song_data["title"]
    song.artist = song_data["singer"]
    song.availability = song_data["brand"]
    song.difficulty_average = 0.0
  end
end


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
