# typed: true
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
  has_many :playlist_tracks
  has_many :playlists, through: :playlist_tracks
  has_many :plays

  def spotify_uri
    "spotify:track:#{id}"
  end

  def avg_progress_pct
    avg_progress_time = self.plays.average(:progress_ms)
    return avg_progress_time / self.duration_ms.to_f
  end

  def should_remove?
    last_n_plays = self.plays.last(SpotifyPlaylist::LAST_N_PLAYS_TO_CONSIDER)

    return false if last_n_plays.empty?

    skip_rate = last_n_plays.count(&:skipped?) / last_n_plays.size.to_f
    skip_rate >= SpotifyPlaylist::SKIP_RATE_THRESHOLD
  end

  class << self
    def find_or_create_from_item(track_item)
      track_item.deep_symbolize_keys!
      track = find_or_create_by(track_item.slice(:id)) do |t|
        t.assign_attributes(track_item.slice(*Track.attributes))
      end

      return track unless track.id_previously_changed? # was it newly created?

      artists = track_item[:artists].map { |artist| Artist.find_or_create_by(artist.slice(*Artist.attributes)) }
      track.artists = artists
      return track
    end
  end
end
