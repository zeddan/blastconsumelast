# coding: UTF-8
require "httparty"
require "json"

def get_token
  headers = {
    "Authorization": "Basic " + Base64.strict_encode64(ENV["BCL_CLIENT_ID"] + ':' + ENV["BCL_CLIENT_SECRET"]),
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

def send_sms(number, message)
  headers = {
    "Authorization": "Basic " + Base64.strict_encode64(ENV["ELK46_USERNAME"] + ":" + ENV["ELK46_PASSWORD"])
  }
  body = {
    from: "BlastersInc",
    to: number,
    message: message
  }
  response = HTTParty.post("https://api.46elks.com/a1/sms", headers: headers, body: body)
  log(response)
  response
end

def send_sms_by_user(playlist, track)
  file = JSON.parse(File.read("latest.json"))
  case file["added_by"]
  when "zdn" then
    send_sms(ENV["ALICE_NUMBER"], sms_message_body("Larsa", playlist, track))
  when "kalasmelon" then
    send_sms(ENV["ROBIN_NUMBER"], sms_message_body("Alice", playlist, track))
  end
end

def sms_message_body(added_by, playlist, track)
  position = playlist["tracks"]["items"].index { |i| i["track"]["id"] == track["track"]["id"] } + 1
  artists = track["track"]["artists"].map { |a| a["name"] }.join(", ")
  track_name = track["track"]["name"]
  track_url = track["track"]["external_urls"]["spotify"]

  <<-MESSAGE
  "Ny låt tillagd av #{added_by}! ✨ Kolla låt nummer #{position} så hittar du #{artists} - #{track_name} 🎵

Lyssna: #{track_url}"
  MESSAGE
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

def log(str)
  File.write("blastconsumelast.log", str, mode: "a")
end

token = get_token
response = get_playlist(token)

latest_addition = response["tracks"]["items"].sort_by { |t| t["added_at"] }.last

save_file(latest_addition) unless File.exist?("latest.json")

if new_track?(latest_addition)
  save_file(latest_addition)
  send_sms_by_user(response, latest_addition)
end
