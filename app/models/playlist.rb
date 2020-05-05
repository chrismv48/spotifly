# == Schema Information
#
# Table name: playlists
#
#  id          :string           not null, primary key
#  deleted_at  :datetime
#  description :string
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Playlist < ApplicationRecord
  has_many :playlist_tracks
  has_many :tracks, through: :playlist_tracks
  has_many :active_playlist_tracks, -> { active }, class_name: "PlaylistTrack"
  has_many :active_tracks, through: :active_playlist_tracks, source: :track
  has_many :artists, through: :tracks

  # this is technically wrong but good for now
  has_many :plays, through: :tracks

  def top_tracks
    active_tracks.includes(:plays).sort_by do |track|
      play_count = track.plays.size
      total_ms_played = track.plays.sum(:progress_ms)
      avg_playthrough_ratio = total_ms_played / track.duration_ms * play_count
      1 - avg_playthrough_ratio
    end
  end

  def add_track_items(track_items)
    tracks = track_items.map { |track_item| Track.create_from_item(track_item) }
    self.tracks << tracks
    return tracks
  end

  class << self

    def create_from_item(playlist_item, track_items: [])
      ActiveRecord::Base.transaction do
        playlist_item.deep_symbolize_keys!

        playlist = Playlist
                     .find_or_initialize_by(id: playlist_item[:id])

        playlist.update_attributes!(
          {
            name: playlist_item[:name],
            description: playlist_item[:description]
          }
        )

        current_playlist_tracks = playlist.active_tracks
        tracks = track_items.map { |track_item| Track.create_from_item(track_item) }

        tracks_to_remove = current_playlist_tracks - tracks
        PlaylistTrack.active.where(playlist_id: playlist.id, track_id: tracks_to_remove.pluck(:id)).update_all(deleted_at: Time.now)

        tracks_to_add = tracks - current_playlist_tracks
        playlist.tracks << tracks_to_add

        return playlist
      end
    end
  end
end
