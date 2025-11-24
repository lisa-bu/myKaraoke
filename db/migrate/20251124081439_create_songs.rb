class CreateSongs < ActiveRecord::Migration[7.1]
  def change
    create_table :songs do |t|
      t.string :name
      t.string :artist
      t.string :ISRC
      t.jsonb :availability
      t.float :difficulty_average
      t.timestamps
    end
  end
end
