require "spotify_poller"

namespace :poll_spotify do
  poller = SpotifyPoller.new
  poller.run!
end
