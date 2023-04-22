require 'spotify_poller'

Rails.application.configure do
  config.after_initialize do
    # poller = SpotifyPoller.new
    # poller.run!
  end
end

