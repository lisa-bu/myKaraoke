class AddSpotifyIdToSongs < ActiveRecord::Migration[7.1]
  def change
    add_column :songs, :spotify_id, :string
  end
end
