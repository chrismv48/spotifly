# typed: true
class CreatePlays < ActiveRecord::Migration[6.0]
  def change
    create_table :plays do |t|
      t.string :track_id, null: false, index: true
      t.string :playlist_id, index: true
      t.integer :progress_ms, null: false

      t.timestamps
    end
  end
end
