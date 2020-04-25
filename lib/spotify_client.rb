require 'http'

# For auth flow, see https://developer.spotify.com/documentation/general/guides/authorization-guide/

class SpotifyClient

  attr_reader :access_token

  CLIENT_ID = Rails.application.credentials.spotify[:client_id]
  CLIENT_SECRET = Rails.application.credentials.spotify[:client_secret]

  DEFAULT_USER_ID = 1

  AUTH_CODE = "AQCZ82jCyxKBUiIG1tRc_WwGi1V5z5Hmt6JgoJtHWPtB8hcf7QDVXG5UmbdQ9IFFk065IMFikPxPV6aYIKQxtSmvC5eQowjDVhlqOZm3dgetrXQHrwedI4PTAewjwNWa4rbXMbb77FP5lSD-QFdyfZdWX2MNtoxmaokoYhcNmgvRnuPTWmO3MNBzH9UpTn9OST3wZg"
  REDIRECT_URI = "http://localhost:3000/spotify_auth/oauth_callback".freeze

  SCOPES = [
    "user-read-playback-state",
    "user-modify-playback-state",
    "user-read-currently-playing",
    "streaming",
    "app-remote-control",
    "user-read-email",
    "user-read-private",
    "playlist-read-collaborative",
    "playlist-modify-public",
    "playlist-read-private",
    "playlist-modify-private",
    "user-library-modify",
    "user-library-read",
    "user-top-read",
    "user-read-playback-position",
    "user-read-recently-played",
    "user-follow-read",
    "user-follow-modify",
  ]

  BASE_URL = "https://api.spotify.com/v1/me"

  def initialize
    @user_token_data = SpotifyUserToken.find_or_create_by!(id: DEFAULT_USER_ID)
    @http = HTTP.use(logging: {logger: Rails.logger})

    if @user_token_data.access_token.nil?
      if @user_token_data.oauth_code
        get_access_token!
      else
        raise "No access token/oauth code found, go get it: #{get_user_authorization_url}"
      end
    end
  end

  def request
    @http
      .auth("Bearer #{@user_token_data.access_token}")
      .headers(
        accept: "application/json",
        content_type: "application/json"
      )
  end

  def get(*args)
    response = request.get(*args)

    if token_needs_to_be_refreshed?(response)
      refresh_access_token!
      response = request.get(*args)
    end

    return response
  end

  def get_currently_playing
    response = self.get(BASE_URL + "/player/currently-playing")
    # 204 means nothing is playing
    if response.code == 200
      parsed_response = response.parse
      # FYI: it's possible for this to return a track that's paused (check is_playing)
      timestamp = parsed_response["timestamp"]
      progress_ms = parsed_response["progress_ms"]
      item = parsed_response["item"]
      item_id = item["id"]
      item_duration_ms = item["duration_ms"]
      item_name = item["name"]
      item_popularity = item["popularity"]
      artists = item["artists"].map { |artist| artist.slice('id', 'name') }


    end
    return response
  end

  def get_user_authorization_url
    auth_url = "https://accounts.spotify.com/authorize"
    params = {
      client_id: CLIENT_ID,
      response_type: 'code',
      redirect_uri: REDIRECT_URI,
      scope: SCOPES.join(" ")
    }

    resp = @http.get(auth_url, params: params)
    return resp["Location"]
  end

  def refresh_access_token!
    refresh_token_url = "https://accounts.spotify.com/api/token"

    refresh_token = @user_token_data.refresh_token

    params = {
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      grant_type: "refresh_token",
      refresh_token: refresh_token,
    }

    request = @http
                .headers(
                  content_type: "application/x-www-form-urlencoded",
                  accept: "application/json"
                )
    resp = request.post(refresh_token_url, form: params)

    if resp.code != 200
      raise RuntimeError("Something went wrong with the response: #{resp}")
    end

    parsed_response = resp.parse
    @user_token_data.access_token = parsed_response["access_token"]

    if parsed_response["refresh_token"].present?
      @user_token_data.refresh_token = parsed_response["refresh_token"]
    end

    @user_token_data.save!
  end

  def token_needs_to_be_refreshed?(response)
    if response.code == 401
      return response.parse["error"]["message"] == "The access token expired"
    end

    return false
  end

  def get_access_token!
    access_token_url = "https://accounts.spotify.com/api/token"

    params = {
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      grant_type: "authorization_code",
      code: @user_token_data.oauth_code,
      redirect_uri: REDIRECT_URI,
    }

    request = @http
                .headers(
                  content_type: "application/x-www-form-urlencoded",
                  accept: "application/json"
                )

    resp = request.post(access_token_url, form: params)

    if resp.code != 200
      raise RuntimeError("Something went wrong with the response: #{resp}")
    end

    parsed_response = resp.parse

    @user_token_data.access_token = parsed_response["access_token"]
    @user_token_data.refresh_token = parsed_response["refresh_token"]
    @user_token_data.save!
  end
end
