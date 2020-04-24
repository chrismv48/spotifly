require "spotify_poller"
task :poll_spotify do
  poller = SpotifyPoller.new
  poller.run!
end
