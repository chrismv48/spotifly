require "spotify_playlist"
task :poll_spotify do
  spotify_playlists = SpotifyPlaylist.build_many_from_query
  spotify_playlists.each do |spotify_playlist|
    spotify_playlist.populate!
  end
end
