require "httparty"

headers = {
  "Authorization": "Basic " + Base64.encode64(ENV["BCL_CLIENT_ID"] + ':' + ENV["BCL_CLIENT_SECRET"]).tr("\n", ""),
  "Content-Type": "application/x-www-form-urlencoded"
}
body = {
  grant_type: "client_credentials"
}
url = "https://accounts.spotify.com/api/token"

token = HTTParty.post(url, headers: headers, body: body)["access_token"]

header = { "Authorization": "Bearer #{token}" }
playlist_id = "1avlVZyB7d7dLsSepjbuIm"
playlist_url = "https://api.spotify.com/v1/playlists/#{playlist_id}"

response = HTTParty.get(playlist_url, headers: header)

puts response["tracks"]["items"].sort_by { |t| t["added_at"] }

