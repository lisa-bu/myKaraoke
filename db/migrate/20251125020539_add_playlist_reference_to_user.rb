class AddPlaylistReferenceToUser < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :playlist, foreign_key: true
  end
end
