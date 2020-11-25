# typed: true
require 'sorbet-runtime'

class SpotifyContextObjectType < T::Struct
  include BaseStruct

  # def initialize(args)
  #   args[:type] = SpotifyContextTypesEnum.deserialize(args[:type])
  #   super(args)
  # end

  const :external_urls, SharedTypes::ExternalUrls
  const :href, String
  const :type, String#SpotifyContextTypesEnum
  const :uri, String
end