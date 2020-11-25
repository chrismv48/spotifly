# typed: false
# require 'sorbet-runtime'

class CurrentlyPlayingType < T::Struct
  include BaseStruct

  def initialize(args)
    item, context = args["item"], args["context"]
    new_args = {
        play: {
            track_id: item["id"],
            progress_ms: args["progress_ms"],
            playlist_id: context["uri"][/.*playlist:(.*)/, 1]
        },
        track: {
            id: item["id"],
            name: item["name"],
            duration_ms: item["duration_ms"],
            popularity: item["popularity"],
            artists: item["artists"].map { |artist| artist.slice("id", "name").symbolize_keys }
        }
    }
    super(new_args)
  end

  # prop :play, {
  #     track_id: String,
  #     progress_ms: Integer,
  #     playlist_id: T.nilable(String),
  # }
  # prop :track, {
  #     id: String,
  #     name: String,
  #     duration_ms: Integer,
  #     popularity: Integer,
  #     artists: T::Array[
  #         {
  #             id: String,
  #             name: String
  #         }
  #     ]
  # }
  prop :play, T::Hash[Symbol, T.untyped]
  prop :track, T.nilable(SpotifyTrackType)

end