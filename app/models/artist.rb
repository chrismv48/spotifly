# typed: true
# == Schema Information
#
# Table name: artists
#
#  id         :string           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Artist < ApplicationRecord
  has_many :artists_tracks, inverse_of: :artist
  has_many :track_items, through: :artists_tracks

  validates_uniqueness_of :id

  accepts_nested_attributes_for :track_items

  class << self
    def build_from_item(artist_item)
      artist_item.deep_symbolize_keys!

      new(
        id: artist_item[:id],
        name: artist_item[:name],
      )
    end
  end
end
