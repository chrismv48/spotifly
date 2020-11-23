# typed: true
class CreateArtistsTracks < ActiveRecord::Migration[6.0]
  def change
    create_table :artists_tracks do |t|
      t.string :artist_id, null: false, index: true
      t.string :track_id, null: false, index: true

      t.timestamps
    end
  end
end
