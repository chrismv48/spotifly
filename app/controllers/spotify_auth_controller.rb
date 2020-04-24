class SpotifyAuthController < ApplicationController
  def oauth_callback
    code = params["code"]
    Rails.cache.write("oauth_code", code)
    head :no_content
  end
end
