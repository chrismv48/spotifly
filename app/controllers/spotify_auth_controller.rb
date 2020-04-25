require "spotify_client"

class SpotifyAuthController < ApplicationController
  def oauth_callback
    code = params["code"]
    user_token = SpotifyUserToken.first
    user_token.oauth_code = code
    user_token.save!

    head :no_content
  end
end
