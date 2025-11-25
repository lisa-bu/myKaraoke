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

puts "Cleaning database..."

Friendship.destroy_all
DifficultyRating.destroy_all
Playlist.destroy_all
Song.destroy_all
User.destroy_all
PlaylistSong.destroy_all

puts 'Creating users...'

alesya = User.create!(nickname: "lisa",  email:"alesya@email.com", password: "123456!")
matt   = User.create!(nickname: "matty", email:"matt@email.com",   password: "123456!")
tan    = User.create!(nickname: "tanty", email:"tan@email.com",    password: "123456!")
haris  = User.create!(nickname: "harisu",email:"haris@email.com",  password: "123456!")

users = [alesya, matt, tan, haris]
puts "Created #{users.count} users"

# API

puts "Fetching songs from API..."

songs = []
song_titles.each do |title|
  begin
    url = "https://api.manana.kr/karaoke/song/#{URI.encode_www_form_component(title)}.json"
    response   = URI.open(url).read
    songs_data = JSON.parse(response)

    if songs_data.is_a?(Array)
      songs_data.first(3).each do |song_data|
        song = Song.create!(
          name:  song_data["title"],
          artists: song_data["singer"],
          ISRC: "#{song_data['brand']}-#{song_data['no']}",
          availability: song_data["brand"],
          difficulty_average: 0.0
        )
        songs << song
        puts "Created song: #{song.name} by #{song.artists}"
      end
    end
  rescue => e
    puts "Error fetching '#{title}': #{e.message}"
  end

  sleep(0.5)
end

puts "Created #{songs.count} songs from API"

# create playlist

puts "Creating playlists..."

playlists = users.map do |user|
  Playlist.create!(
    name: "#{user.nickname}'s playlist",
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

Friendship.create!(asker: alesya, receiver: matt)
Friendship.create!(asker: matt,   receiver: tan)
Friendship.create!(asker: tan,    receiver: haris)
Friendship.create!(asker: haris,  receiver: alesya)

# difficulty rating

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

puts "finish"
