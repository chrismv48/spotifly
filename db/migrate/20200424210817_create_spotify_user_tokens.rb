class CreateSpotifyUserTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :spotify_user_tokens do |t|
      t.integer :user_id
      t.string :access_token
      t.string :refresh_token
      t.string :oauth_code
      t.datetime :expires_at

      t.timestamps
    end
  end
end
