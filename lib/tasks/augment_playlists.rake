require "spotify_playlist"
task :augment_playlists do
  spotify_playlists = SpotifyPlaylist.build_many_from_query
  spotify_playlists.each do |spotify_playlist|
    spotify_playlist.augment!
  end
end
