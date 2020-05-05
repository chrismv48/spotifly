class CreatePlaylistTracks < ActiveRecord::Migration[6.0]
  def change
    create_table :playlist_tracks do |t|
      t.string :playlist_id, null: false, index: true
      t.string :track_id, null: false, index: true
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
