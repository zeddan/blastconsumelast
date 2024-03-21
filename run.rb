# coding: UTF-8
require "httparty"
require "json"
require_relative "spotify_client"
require_relative "elk46_client"
require_relative "db"

playlist_id = ENV["PLAYLIST_ID"]

unless playlist_id
  puts "ENV[\"PLAYLIST_ID\"] not found"
  exit 1
end

db = Db.new(playlist_id)
spotify_client = SpotifyClient.new(playlist_id)
sms_client = Elk46Client.new(db.sms_credentials)
logger = Logger.new(db.project_name)

response = spotify_client.get_playlist(id: "1avlVZyB7d7dLsSepjbuIm")
latest_addition = response["tracks"]["items"].sort_by { |t| t["added_at"] }.last
db.save_file(latest_addition) unless File.exist?("latest.json")

sms_client.send_sms_by_user(response, latest_addition)

if db.new_track?(latest_addition)
  db.save_file(latest_addition)
  sms_client.send_sms_by_user(response, latest_addition)
end
