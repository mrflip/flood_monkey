require 'yaml'

class Monk::Glue < Sinatra::Base

  # TODO Add documentation.
  def self.settings(key)
    @settings ||= YAML.load_file(root_path("config", "settings.yml"))[RACK_ENV.to_sym]

    unless @settings.include?(key)
      message = "No setting defined for #{key.inspect}."
      defined?(logger) ? logger.warn(message) : $stderr.puts(message)
    end

    @settings[key]
  end
  
  def settings(key)
    self.class.settings(key)
  end

end

