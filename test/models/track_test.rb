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
require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
