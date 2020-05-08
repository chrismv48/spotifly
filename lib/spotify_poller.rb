require './config/environment.rb'
require "spotify_client"

class SpotifyPoller

  MAX_SLEEP_DURATION = 3
  MIN_SLEEP_DURATION = 0.5

  DEFAULT_RUN_UNTIL_HOUR = 23 # 11pm

  def run!
    sc = SpotifyClient.new

    run_until = Time.now.change({ hour: DEFAULT_RUN_UNTIL_HOUR, min: 0, sec: 0 })
    previously_playing = nil

    while Time.now < run_until
      resp = sc.get_currently_playing
      if resp.code == 204
        Rails.logger.info("Nothing playing...")
        sleep_duration = 15
      elsif resp.code == 200 && !resp.parse["is_playing"]
        Rails.logger.info("Track is paused")
        sleep_duration = 15
      elsif resp.code == 200
        parsed_resp = resp.parse

        currently_playing = build_currently_playing(parsed_resp)

        Rails.logger.info("Playing track: #{currently_playing[:track][:name]} by #{currently_playing[:track][:artists].pluck(:name).to_sentence}")

        if previously_playing && previously_playing[:play][:track_id] != currently_playing[:play][:track_id]
          Rails.logger.info("Creating new Play for #{previously_playing.inspect}")
          persist_currently_playing!(previously_playing)
        end

        progress_pct = currently_playing[:play][:progress_ms] / currently_playing[:track][:duration_ms].to_f
        Rails.logger.info "Progress: #{(progress_pct * 100).round}%"
        sleep_duration = [MAX_SLEEP_DURATION * progress_pct, MIN_SLEEP_DURATION].max.round(2)

        previously_playing = currently_playing
      else
        break
      end

      Rails.logger.info("Sleeping #{sleep_duration}s")
      Rails.logger.info `ps -o rss= -p #{$$}`.to_i
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
    item, context = parsed_response["item"], parsed_response["context"]

    return {
      play: {
        track_id: item["id"],
        progress_ms: parsed_response["progress_ms"],
        playlist_id: context["uri"][/spotify:playlist:(.*)/, 1]
      },
      track: {
        id: item["id"],
        name: item["name"],
        duration_ms: item["duration_ms"],
        popularity: item["popularity"],
        artists: item["artists"].map {|artist| artist.slice("id", "name").symbolize_keys}
      }
    }
  end
end
