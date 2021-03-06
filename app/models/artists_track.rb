# typed: strict
# == Schema Information
#
# Table name: artists_tracks
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  artist_id  :string           not null
#  track_id   :string           not null
#
# Indexes
#
#  index_artists_tracks_on_artist_id  (artist_id)
#  index_artists_tracks_on_track_id   (track_id)
#
class ArtistsTrack < ApplicationRecord
  belongs_to :artist
  belongs_to :track
end
