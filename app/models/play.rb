# == Schema Information
#
# Table name: plays
#
#  id          :bigint           not null, primary key
#  progress_ms :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  playlist_id :string
#  track_id    :string           not null
#
# Indexes
#
#  index_plays_on_playlist_id  (playlist_id)
#  index_plays_on_track_id     (track_id)
#
class Play < ApplicationRecord
  belongs_to :track
end
