class CreatePlaylistsSongs < ActiveRecord::Migration[7.1]
  def change
    create_table :playlists_songs do |t|
      t.references :playlist, null: false, foreign_key: true
      t.references :song, null: false, foreign_key: true
      t.integer :position
      t.timestamps
    end
  end
end
