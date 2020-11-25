# typed: true
require 'sorbet-runtime'

class SpotifyTrackType < T::Struct
  include BaseStruct

  const :album, T.untyped  # we don't use this for anything so leave it untyped for now
  const :artists, T::Array[SpotifyArtistType]
  const :href, String
  const :id, String
  const :name, String
  const :duration_ms, Integer
  const :popularity, Integer
  const :uri, String
end