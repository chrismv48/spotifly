# typed: true

module SharedTypes
  extend T::Sig

  ExternalUrls = T.type_alias { T::Hash[String, String] }
end