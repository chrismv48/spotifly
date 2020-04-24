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
  has_many :artists_tracks
  has_many :tracks, through: :artists_tracks
end
