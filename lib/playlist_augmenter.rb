# frozen_string_literal: true

class PlaylistAugmenter
  class << self
    def augment_all!
      Rails.logger.info('Starting augmentation process')
      spotify_playlists = SpotifyPlaylist.build_many_from_query
      spotify_playlists.each do |spotify_playlist|
        Rails.logger.info("Augmenting playlist: #{spotify_playlist.playlist.name}")
        spotify_playlist.augment!
      end
      Rails.logger.info('Augmentation process complete!')
    end
  end
end
