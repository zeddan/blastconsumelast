require_relative "db"

class Elk46Client
  def initialize(playlist_id, from, to)
    @playlist_id = playlist_id
    @from = from
    @to = to
    @db = Db.new(playlist_id)
  end

  def send_sms(message)
    headers = {
      "Authorization": "Basic " + Base64.strict_encode64(ENV["ELK46_USERNAME"] + ":" + ENV["ELK46_PASSWORD"])
    }

    body = {
      from: @from,
      to: @to,
      message: message
    }

    # HTTParty.post("https://api.46elks.com/a1/sms", headers: headers, body: body)
    puts "SMS SENT FROM #{@from} to #{@to} WITH MESSAGE #{message}"
  end

  def send_sms_by_user(playlist, track)
    file = db.read_file
    case file["added_by"]
    when "zdn" then
      send_sms("BlastersInc", ENV["ALICE_NUMBER"], sms_message_body("Larsa", playlist, track))
    when "kalasmelon" then
      send_sms("BlastersInc", ENV["ROBIN_NUMBER"], sms_message_body("Alice", playlist, track))
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
end
