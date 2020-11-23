# typed: true
class CreateArtists < ActiveRecord::Migration[6.0]
  def change
    create_table :artists, id: false do |t|
      t.string :id, primary_key: true
      t.string :name

      t.timestamps
    end
  end
end
