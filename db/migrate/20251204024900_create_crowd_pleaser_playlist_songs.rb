class CreateCrowdPleaserPlaylistSongs < ActiveRecord::Migration[7.1]
  def change
    create_table :crowd_pleaser_playlist_songs do |t|
      t.references :crowd_pleaser_playlist, null: false, foreign_key: true
      t.references :song, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
