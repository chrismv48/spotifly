class CreateTracks < ActiveRecord::Migration[6.0]
  def change
    create_table :track_items, id: false do |t|
      t.string :id, primary_key: true
      t.string :name
      t.integer :duration_ms
      t.float :popularity
      t.float :acousticness
      t.float :danceability
      t.float :energy
      t.float :instrumentalness
      t.float :liveness
      t.float :loudness
      t.float :speechiness
      t.float :valence
      t.float :tempo

      t.timestamps
    end
  end
end
