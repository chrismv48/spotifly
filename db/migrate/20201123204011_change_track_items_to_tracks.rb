class ChangeTrackItemsToTracks < ActiveRecord::Migration[6.0]
  def change
    rename_table :track_items, :tracks
  end
end
