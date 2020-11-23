# typed: true
class CreatePlaylists < ActiveRecord::Migration[6.0]
  def change
    create_table :playlists, id: false do |t|
      t.string :id, primary_key: true
      t.string :name, null: false
      t.string :description
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
