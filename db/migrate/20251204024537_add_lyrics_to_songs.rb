class AddLyricsToSongs < ActiveRecord::Migration[7.1]
  def change
    add_column :songs, :lyrics, :text
  end
end
