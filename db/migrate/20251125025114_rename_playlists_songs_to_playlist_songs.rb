class RenamePlaylistsSongsToPlaylistSongs < ActiveRecord::Migration[7.1]
  def change
    rename_table :playlists_songs, :playlist_songs
  end
end
