require './config/environment.rb'
require 'spotify_client'

class SpotifyPlaylist
  attr_reader :playlist

  DESCRIPTION_KEYWORD = '!dynamic' # let's us know this playlist should be considered
  MAX_PLAYLIST_SIZE = 100
  MIN_PLAYLIST_SIZE = 20
  TARGET_PCT_TRACKS_PLAYED = 0.65
  SKIP_RATE_THRESHOLD = 0.5
  LAST_N_PLAYS_TO_CONSIDER = 5

  def initialize(playlist)
    @playlist = playlist
    @spotify_client = SpotifyClient.new
    @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  end

  def log(msg)
    @logger.tagged(self.playlist.name) { @logger.info msg }
  end

  def augment!
    # I think we need a sync step here?
    self.cull!
    self.populate!
    self.reorder_by_last_played!
  end

  # Remove poor performing tracks
  def cull!
    tracks_to_cull = @playlist.active_tracks.includes(:plays).select(&:should_remove?)

    log("Found #{tracks_to_cull.size} to cull: #{tracks_to_cull.pluck(:name).to_sentence}")

    return if tracks_to_cull.empty?

    @playlist
      .playlist_tracks
      .where(track_id: tracks_to_cull.pluck(:id))
      .update_all(deleted_at: Time.now)

    @spotify_client.remove_tracks_from_playlist!(
      playlist_id: @playlist.id,
      track_uris: tracks_to_cull.map(&:spotify_uri)
    )
  end

  # Finds new music similar to the top tracks on the playlist.
  def populate!
    if num_tracks_to_add.zero?
      log('Playlist does not have enough playtime, skipping populate step.')
      return
    end

    seed_tracks = @playlist.top_tracks.first(3)
    return if seed_tracks.empty?

    log("Using #{seed_tracks.size} to seed: #{seed_tracks.pluck(:name).to_sentence}")

    response = @spotify_client.get_recommended_tracks(seed_track_ids: seed_tracks.pluck(:id))

    previously_added_track_ids = @playlist.playlist_tracks.pluck(:track_id)

    recommended_track_items = response.parse['tracks']
    filtered_track_items = recommended_track_items.reject { |track_item| track_item['id'].in?(previously_added_track_ids) }

    track_items_to_add = filtered_track_items.first(num_tracks_to_add)
    return unless track_items_to_add.any?

    added_tracks = @playlist.add_track_items(track_items_to_add)
    @spotify_client.add_tracks_to_playlist!(playlist_id: @playlist.id, track_uris: added_tracks.map(&:spotify_uri))
    log("Added #{added_tracks.size} tracks: #{added_tracks.pluck(:name).to_sentence}")
  end

  def reorder_by_last_played!
    ordered_tracks = @playlist.active_tracks.includes(:plays).sort_by do |track|
      last_play = track.plays.last
      last_play.nil? ? 0 : last_play.created_at.to_i
    end

    return if ordered_tracks.empty?

    @spotify_client.set_playlist_tracks!(playlist_id: @playlist.id, track_uris: ordered_tracks.map(&:spotify_uri))
    log('Reordered tracks by least recently played')
  end

  def pct_tracks_played
    current_count = @playlist.active_tracks.size
    num_played_tracks = @playlist.active_tracks.count { |track| track.plays.any? }
    return num_played_tracks / current_count.to_f
  end

  def num_tracks_to_add
    current_count = @playlist.active_tracks.size
    num_played_tracks = @playlist.active_tracks.includes(:plays).count { |track| track.plays.any? }
    new_count = [(num_played_tracks / TARGET_PCT_TRACKS_PLAYED).to_i, current_count].max
    return [new_count.clamp(MIN_PLAYLIST_SIZE, MAX_PLAYLIST_SIZE) - current_count, 0].max
  end

  class << self

    def build_many_from_query
      client = SpotifyClient.new
      response = client.get_playlists
      playlist_items = response.parse['items']
      spotify_playlists = []
      playlist_items.each do |playlist_item|
        next unless dynamic?(description: playlist_item['description'])

        tracks_resp = client.get_playlist_tracks(playlist_item['id'])
        track_items = tracks_resp.parse['items'].pluck('track')

        playlist = Playlist.create_from_item(playlist_item, track_items:)

        spotify_playlists.push(SpotifyPlaylist.new(playlist))
      end

      return spotify_playlists
    end

    def dynamic?(description:)
      description.include? DESCRIPTION_KEYWORD
    end
  end
end
