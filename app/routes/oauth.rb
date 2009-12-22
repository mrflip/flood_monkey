class Main

  # ===========================================================================
  #
  # Perform OAuth dance
  #
  get "#{MYSPACE_URL_BASE}/auth" do
    @access_token  = nil
    @request_token = consumer.get_request_token(:oauth_callback => OAUTH_SETUP[:oauth_callback])
    save_request_token_in_session
    redirect @request_token.authorize_url(:oauth_callback => OAUTH_SETUP[:oauth_callback])
  end

  post "#{MYSPACE_URL_BASE}/cb" do
    handle_oauth_callback
  end
  get "#{MYSPACE_URL_BASE}/cb" do
    handle_oauth_callback
  end
  def handle_oauth_callback
    @request_token = ::OAuth::RequestToken.new(consumer, session[:request_token], session[:request_token_secret])
    @access_token  = @request_token.get_access_token OAUTH_SETUP
    save_access_token_in_session
    [session.inspect, "<a href='subscribe'>subscribe</a>"].join("<br/>\n")
  end

end
