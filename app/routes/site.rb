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

end
