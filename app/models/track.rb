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
  has_many :playlists, through: :playlists
  has_many :plays

  def spotify_uri
    "spotify:track:#{id}"
  end

  class << self
    def create_from_item(track_item)
      ActiveRecord::Base.transaction do
        track_item.deep_symbolize_keys!
        track = find_or_create_by(track_item.slice(:id)) do |track|
          track.assign_attributes(track_item.slice(*Track.attributes))
        end

        unless track.id_previously_changed?   # was it newly created?
          return track
        end

        artists = track_item[:artists].map {|artist| Artist.find_or_create_by(artist.slice(*Artist.attributes))}
        track.artists = artists
        return track
      end
    end
  end
end
