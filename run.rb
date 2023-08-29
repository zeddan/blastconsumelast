require "httparty"
require "json"

def get_token
  headers = {
    "Authorization": "Basic " + Base64.encode64(ENV["BCL_CLIENT_ID"] + ':' + ENV["BCL_CLIENT_SECRET"]).tr("\n", ""),
    "Content-Type": "application/x-www-form-urlencoded"
  }
  body = { grant_type: "client_credentials" }
  url = "https://accounts.spotify.com/api/token"

  HTTParty.post(url, headers: headers, body: body)["access_token"]
end

def get_playlist(token)
  header = { "Authorization": "Bearer #{token}" }
  playlist_id = "1avlVZyB7d7dLsSepjbuIm"
  playlist_url = "https://api.spotify.com/v1/playlists/#{playlist_id}"

  HTTParty.get(playlist_url, headers: header)
end

def send_sms(track)
  
end

def save_file(track)
  data = {
    added_at: track["added_at"],
    added_by: track["added_by"]["id"]
  }
  File.write("latest.json", data.to_json)
end

def new_track?(playlist_track)
  file = JSON.parse(File.read("latest.json"))
  to_date(playlist_track["added_at"]) > to_date(file["added_at"])
end

def to_date(str)
  DateTime.parse(str)
end

token = get_token
response = get_playlist(token)

latest_addition = response["tracks"]["items"].sort_by { |t| t["added_at"] }.last

save_file(latest_addition) unless File.exist?("latest.json")

new_track = new_track?(latest_addition)

if new_track
  save_file(latest_addition)
  send_sms(latest_addition)
end
