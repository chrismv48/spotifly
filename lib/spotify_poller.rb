require './config/environment'
require 'spotify_client'

# This class is responsible for polling the Spotify API to check if anything is being played. If it is, we create a play record.
# When a track is skipped, we detect this via polling and update the play record with the track progress. This ultimately
# let's us know when tracks are skipped which let's us make decisions about what to keep. We have to do it this way because
# the Spotify API doesn't have the necessary data. The recently played endpoint comes close, but it doesn't record plays
# where the track was played for 30s or less.
class SpotifyPoller

  MAX_SLEEP_DURATION = 3
  MIN_SLEEP_DURATION = 0.5

  DEFAULT_RUN_UNTIL_HOUR = 23 # 11pm
  DEFAULT_SLEEP_DURATION = 15

  AUGMENT_EVERY_N_PLAYS = 10

  def run!
    sc = SpotifyClient.new

    previously_playing = nil
    plays_since_augment = 0

    loop do
      resp = sc.get_currently_playing
      sleep_duration = DEFAULT_SLEEP_DURATION

      if resp.code == 200 && resp.parse['is_playing']
        parsed_resp = resp.parse

        currently_playing = build_currently_playing(parsed_resp)

        Rails.logger.info("Playing track: #{currently_playing[:track][:name]} by #{currently_playing[:track][:artists].pluck(:name).to_sentence}")

        if previously_playing && previously_playing[:play][:track_id] != currently_playing[:play][:track_id]
          Rails.logger.info("Creating new Play for #{previously_playing.inspect}")
          persist_currently_playing!(previously_playing)
        end
        plays_since_augment += 1

        if plays_since_augment >= AUGMENT_EVERY_N_PLAYS
          # This is not efficient because it is augmenting all playlists regardless of
          # activity. Eventually should refactor to only augment relevant playlist(s)
          PlaylistAugmenter.augment_all!
          plays_since_augment = 0
        end

        progress_pct = currently_playing[:play][:progress_ms] / currently_playing[:track][:duration_ms].to_f
        Rails.logger.debug "Progress: #{(progress_pct * 100).round}%"
        sleep_duration = [MAX_SLEEP_DURATION * progress_pct, MIN_SLEEP_DURATION].max.round(2)

        previously_playing = currently_playing
      elsif resp.code == 204
        Rails.logger.debug('Nothing playing...')
      elsif resp.code == 200 && !resp.parse['is_playing']
        Rails.logger.debug('Track is paused')
      else
        # TODO: Should probably make this more robust, ie retries
        Rails.logger.error 'Encountered response error, stopping!'
        break
      end

      Rails.logger.debug("Sleeping #{sleep_duration}s")
      sleep(sleep_duration)
    end
  end

  def persist_currently_playing!(currently_playing)
    ActiveRecord::Base.transaction do
      track = currently_playing[:track]
      Track.find_or_create_from_item(track)
      Play.create!(currently_playing[:play])
    end
  end

  def build_currently_playing(parsed_response)
    item, context = parsed_response['item'], parsed_response['context']
    spotify_uri = context&.dig('uri') || ''
    playlist_id = spotify_uri[/.*playlist:(.*)/, 1]
    return {
      play: {
        track_id: item['id'],
        progress_ms: parsed_response['progress_ms'],
        playlist_id:
      },
      track: {
        id: item['id'],
        name: item['name'],
        duration_ms: item['duration_ms'],
        popularity: item['popularity'],
        artists: item['artists'].map { |artist| artist.slice('id', 'name').symbolize_keys }
      }
    }
  end
end
