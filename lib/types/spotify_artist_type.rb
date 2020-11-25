# typed: true
require 'sorbet-runtime'

class SpotifyArtistType < T::Struct
  include BaseStruct

  const :external_urls, SharedTypes::ExternalUrls
  const :href, String
  const :id, String
  const :name, String
  const :type, String
  const :uri, String
end