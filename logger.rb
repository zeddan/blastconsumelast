class Logger
  def initialize(project_name)
    @project_name = project_name
  end

  def log(str)
    File.write("#{project_name}.log", str, mode: "a")
  end
end
