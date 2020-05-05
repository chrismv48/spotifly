# == Schema Information
#
# Table name: playlist_tracks
#
#  id          :bigint           not null, primary key
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  playlist_id :string           not null
#  track_id    :string           not null
#
# Indexes
#
#  index_playlist_tracks_on_playlist_id  (playlist_id)
#  index_playlist_tracks_on_track_id     (track_id)
#
require 'test_helper'

class PlaylistTrackTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
