::ROOT_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? ::ROOT_DIR

begin
  require "vendor/dependencies/lib/dependencies"
rescue LoadError
  require "dependencies"
end
require "monk/glue"
require "json"
require 'sinatra'
require 'haml'
require 'fileutils'
require 'extlib'
require 'restclient'
require 'oauth'
require 'rack-flash'
# require 'dm-core'
# require 'dm-validations'
# require 'dm-timestamps'

# Load initializers
Dir[Monk::Glue.root_path("config/initializers/*.rb")].each{|file| require file.gsub(/\.rb$/, '\1') }

class Main < Monk::Glue
  set :app_file, __FILE__
  configure :production do
    set :static,           false
  end
  configure :development, :test do
    set :static,           true
    set :clean_trace,      true
  end
  set :logging,          false

  # use Rack::Session::Cookie,
  #   :key          => 'rack.session',
  #   :domain       => 'infinitemonkeys.info',
  #   :path         => '/',
  #   :expire_after => 2592000,
  #   :secret       => settings(:session_secret)
  set :sessions, true
  use Rack::Flash, :accessorize => [:success, :notice, :error]
end

# Load all application files.
Dir[Monk::Glue.root_path("app/**/*.rb")].each do |file|
  require file
end

# # Connect to database.
# sqlite3_path = settings(:sqlite3)[:database]
# DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/#{sqlite3_path}")

# Metal
Main.class_eval do
  use EndpointResponder
end

Main.run! if Main.run?

