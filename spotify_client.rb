# coding: UTF-8
require "httparty"

class SpotifyClient
  def initialize(playlist_id)
    @playlist_id = playlist_id
  end

  def token
    headers = {
      "Authorization": "Basic " + Base64.strict_encode64(ENV["BCL_CLIENT_ID"] + ':' + ENV["BCL_CLIENT_SECRET"]),
      "Content-Type": "application/x-www-form-urlencoded"
    }
    body = { grant_type: "client_credentials" }
    url = "https://accounts.spotify.com/api/token"

    HTTParty.post(url, headers: headers, body: body)["access_token"]
  end

  def get_playlist
    header = { "Authorization": "Bearer #{token}" }
    playlist_url = "https://api.spotify.com/v1/playlists/#{id}"

    HTTParty.get(@playlist_url, headers: header)
  end
end
