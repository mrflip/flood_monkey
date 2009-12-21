require "init"

Main.class_eval do
  set :environment, :development # :production

  set :sessions,           true
  configure :production do
    set :static,           false
    set :logging,          false
  end
  configure :development, :test do
    set :static,           true
    set :logging,          true
  end
end

run Main
