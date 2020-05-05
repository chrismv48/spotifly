require './config/environment.rb'
require "spotify_client"

class SpotifyPlaylist
  attr_reader :playlist

  DESCRIPTION_KEYWORD = "!dynamic" # let's us know this playlist should be considered
  MAX_PLAYLIST_SIZE = 100
  MIN_PLAYLIST_SIZE = 20
  PLAYLIST_GROWTH_RATE = 1.3

  def initialize(playlist)
    @playlist = playlist
    @spotify_client = SpotifyClient.new
  end

  def augment!
    self.cull!
    self.populate!
  end

  def cull!
    # find tracks that have been skipped twice in a row
    tracks_to_cull = @playlist.active_tracks.includes(:plays).select do |track|
      track.plays.count {|play| play.skipped?} >= 2
    end

    return unless tracks_to_cull.any?

    Rails.logger.info("Found #{tracks_to_cull.size} to cull: #{tracks_to_cull.pluck(:name).to_sentence}")

    @playlist
      .playlist_tracks
      .where(track_id: tracks_to_cull.pluck(:id))
      .update_all(deleted_at: Time.now)

    @spotify_client.remove_tracks_from_playlist(playlist_id: @playlist.id, track_uris: tracks_to_cull.map(&:spotify_uri))
  end

  def populate!
    seed_tracks = @playlist.top_tracks.first(3)
    return if seed_tracks.empty?

    Rails.logger.info("Using #{seed_tracks.size} to seed: #{seed_tracks.pluck(:name).to_sentence}")

    response = @spotify_client.get_recommended_tracks(seed_track_ids: seed_tracks.pluck(:id))

    previously_added_track_ids = @playlist.playlist_tracks.pluck(:track_id)

    recommended_track_items = response.parse["tracks"]
    filtered_track_items = recommended_track_items.reject {|track_item| track_item["id"].in?(previously_added_track_ids)}

    track_items_to_add = filtered_track_items.first(num_tracks_to_add)
    return unless track_items_to_add.any?

    added_tracks = @playlist.add_track_items(track_items_to_add)
    @spotify_client.add_tracks_to_playlist(playlist_id: @playlist.id, track_uris: added_tracks.map(&:spotify_uri))
    Rails.logger.info("Added #{added_tracks.size} tracks: #{added_tracks.pluck(:name).to_sentence}")
  end

  def pct_tracks_played
    current_count = @playlist.active_tracks.size
    num_played_tracks = @playlist.active_tracks.count {|track| track.plays.any?}
    return num_played_tracks / current_count.to_f
  end

  def num_tracks_to_add
    current_count = @playlist.active_tracks.size
    new_count = (current_count * PLAYLIST_GROWTH_RATE * pct_tracks_played).to_i
    return new_count.clamp(MIN_PLAYLIST_SIZE, MAX_PLAYLIST_SIZE) - current_count
  end

  class << self
    def build_many_from_query
      client = SpotifyClient.new
      response = client.get_playlists
      playlist_items = response.parse["items"]
      spotify_playlists = []
      playlist_items.each do |playlist_item|
        next unless dynamic?(description: playlist_item["description"])

        tracks_resp = client.get_playlist_tracks(playlist_item["id"])
        track_items = tracks_resp.parse["items"].pluck("track")

        playlist = Playlist.create_from_item(playlist_item, track_items: track_items)

        spotify_playlists.push(SpotifyPlaylist.new(playlist))
      end

      return spotify_playlists
    end

    def dynamic?(description:)
      description.include? DESCRIPTION_KEYWORD
    end
  end
end
