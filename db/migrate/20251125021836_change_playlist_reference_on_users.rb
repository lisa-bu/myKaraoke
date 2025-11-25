class ChangePlaylistReferenceOnUsers < ActiveRecord::Migration[7.1]
  def change
    remove_reference :users, :playlist, foreign_key: true
    add_reference :users, :current_playlist, foreign_key: { to_table: :playlists }, null: true
  end
end
