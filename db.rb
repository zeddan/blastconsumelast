class Db
  def initialize(playlist_id)
    @playlist_id = playlist_id
  end

  def to_date(str)
    DateTime.parse(str)
  end

  def read_file
    JSON.parse(File.read("#{playlist_id}.json"))
  end

  def save_file(track)
    data = {
      added_at: track["added_at"],
      added_by: track["added_by"]["id"]
    }
    File.write("#{playlist_id}.json", data.to_json)
  end

  def new_track?(playlist_track)
    file = JSON.parse(File.read("#{playlist_id}.json"))
    to_date(playlist_track["added_at"]) > to_date(file["added_at"])
  end
end
