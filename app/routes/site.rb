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
  get "#{MYSPACE_URL_BASE}/?" do
    haml :root
  end

  # Debug
  get %r{.*/debug/?} do
    protected!
    haml :debug
  end

private
  def set_flash messages, now=nil
    if now then messages.each{|type, message| flash.now[type] = message }
    else        messages.each{|type, message| flash[type]     = message } end
  end

end
