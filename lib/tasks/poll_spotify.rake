task :poll_spotify => [:environment] do
  require "spotify_poller"

  poller = SpotifyPoller.new
  poller.run!
end
