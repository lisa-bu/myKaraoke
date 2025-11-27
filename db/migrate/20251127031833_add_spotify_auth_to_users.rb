class AddSpotifyAuthToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :spotify_uid, :string
    add_column :users, :spotify_access_token, :string
    add_column :users, :spotify_refresh_token, :string
    add_column :users, :spotify_expires_at, :datetime
  end
end
