class Main
  get "/" do
    haml :root
  end

  #
  # Help, Terms of Service (tos) and Privacy
  #
  get %r{.*/(help|tos|privacy)$} do
    haml :root_help
  end


  # ===========================================================================
  #
  # Other pages
  #

  # Base controls
  get "#{MYSPACE_URL_BASE}" do
    haml :root
  end
  # KLUDGE -- expose logs to the world
  get "#{MYSPACE_URL_BASE}/logs" do
    File.open("views/log.txt").read
  end

private
  def set_flash messages
    session[:flash].merge!(messages||{})
  end

end
