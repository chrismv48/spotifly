# == Schema Information
#
# Table name: tracks
#
#  id               :string           not null, primary key
#  acousticness     :float
#  danceability     :float
#  duration_ms      :integer
#  energy           :float
#  instrumentalness :float
#  liveness         :float
#  loudness         :float
#  name             :string
#  popularity       :float
#  speechiness      :float
#  tempo            :float
#  valence          :float
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Track < ApplicationRecord
  has_many :artists_tracks
  has_many :artists, through: :artists_tracks
  has_many :plays
end
