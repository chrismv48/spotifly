task :augment_playlists => [:environment] do
  require "spotify_playlist"

  spotify_playlists = SpotifyPlaylist.build_many_from_query
  spotify_playlists.each do |spotify_playlist|
    spotify_playlist.augment!
  end
end
