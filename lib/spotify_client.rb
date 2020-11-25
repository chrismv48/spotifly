require 'http'
require 'url_generator'
require "timeout"

# For auth flow, see https://developer.spotify.com/documentation/general/guides/authorization-guide/

class SpotifyClient
  attr_reader :user_token_data

  CLIENT_ID = Rails.application.credentials.spotify[:client_id]
  CLIENT_SECRET = Rails.application.credentials.spotify[:client_secret]

  # We expect a single record for this user with the proper spotify access artifacts present.
  # NOTE: if starting this app cold, you'll likely get an error that suggests you get a Spotify access code.
  # Once you click on the link, you'll be redirected to a URL with the oauth_code. Save this code in the
  # `spotify_user_tokens` table and everything should be A-OK.
  DEFAULT_USER_ID = 1


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

  def initialize(user_id: DEFAULT_USER_ID)
    @user_token_data = SpotifyUserToken.find_or_create_by!(user_id: user_id)
    @http = HTTP.use(logging: {logger: Rails.logger})
    @consecutive_failed_requests = 0
    if @user_token_data.access_token.nil?
      if @user_token_data.oauth_code
        get_access_token!
      else
        puts "No access token/oauth code found, go get it from\n\n#{get_user_authorization_url}\n\n and paste it here:"
        begin
          Timeout::timeout 30 do
            @user_token_data.oauth_code = STDIN.gets.chomp
            @user_token_data.save!
            get_access_token!
          end
        rescue Timeout::Error
          raise "No access token/oauth code found, go get it and insert it into the DB: #{get_user_authorization_url}"
        end
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

  def api_get(*args)
    response = request.get(*args)

    if token_needs_to_be_refreshed?(response)
      refresh_access_token!
      response = request.get(*args)
    elsif response_is_server_error?(response)
      if @consecutive_failed_requests <= 3
        Rails.logger.info("Retrying failed request after sleeping")
        @consecutive_failed_requests += 1
        sleep(@consecutive_failed_requests * 2)
        api_get(*args)
      else
        # raise error?
      end
    else
      @consecutive_failed_requests = 0
    end

    return response
  end

  def response_is_server_error?(response)
    response.code.to_s.starts_with?('5')
  end

  def get_currently_playing
    response = self.api_get(BASE_URL + "/player/currently-playing")
    return response
  end

  def get_playlists(limit: 50, offset: 0)
    # TODO: need to consider pagination

    params = {
        limit: limit,
        offset: offset
    }

    response = self.api_get(BASE_URL + "/playlists", params: params)
    return response
  end

  def get_playlist_tracks(playlist_id, limit: 100, offset: 0)
    # TODO: need to consider pagination

    params = {
        limit: limit,
        offset: offset
    }

    response = self.api_get("https://api.spotify.com/v1/playlists/#{playlist_id}/tracks", params: params)
    return response
  end

  def get_recommended_tracks(seed_track_ids:)
    url = "https://api.spotify.com/v1/recommendations"
    params = {
        limit: 100,
        seed_tracks: seed_track_ids.join(',')
    }
    response = self.api_get(url, params: params)
    return response
  end

  def add_tracks_to_playlist!(playlist_id:, track_uris:)
    url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"

    params = {
        uris: track_uris.join(",")
    }

    response = request.post(url, params: params)
    return response
  end

  def remove_tracks_from_playlist!(playlist_id:, track_uris:)
    url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"
    payload = {
        tracks: track_uris.map { |track_uri| {uri: track_uri} }
    }

    response = request.delete(url, json: payload)
    return response
  end

  def get_user_authorization_url
    auth_url = "https://accounts.spotify.com/authorize"
    params = {
        client_id: CLIENT_ID,
        response_type: 'code',
        redirect_uri: UrlGenerator.new.spotify_oauth_callback_url,
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
      # if something went wrong with fetching the access token, it's best to clear the oauth token in case it was wrong
      @user_token_data.oauth_token = nil
      @user_token_data.save!
      raise RuntimeError.new("Something went wrong with the response: #{resp}")
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
        redirect_uri: UrlGenerator.new.spotify_oauth_callback_url,
    }

    request = @http
                  .headers(
                      content_type: "application/x-www-form-urlencoded",
                      accept: "application/json"
                  )

    resp = request.post(access_token_url, form: params)

    if resp.code != 200
      raise RuntimeError.new("Something went wrong with the response: #{resp}")
    end

    parsed_response = resp.parse

    @user_token_data.access_token = parsed_response["access_token"]
    @user_token_data.refresh_token = parsed_response["refresh_token"]
    @user_token_data.save!
  end
end
