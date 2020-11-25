# typed: true
require 'sorbet-runtime'

class SpotifyContextTypesEnum < T::Enum
  enums do
    Album = new
    Artist = new
    Playlist = new
  end
end