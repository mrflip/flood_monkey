require 'oauth'
class Main

  before do
    if request.path_info =~ /#{Regexp.escape(MYSPACE_URL_BASE)}/
      set_access_token_from_consumer
    end
  end

  # ===========================================================================
  #
  # Handle publication calls
  #
  post %r{#{MYSPACE_URL_BASE}/(note|music|all)/?$} do
    response_iostr = request.env['rack.input']
    text = process_publication_stream response_iostr
    # Log.info [text.length, request.ip].join("\t")
    "OK #{text.length}"
  end

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

  # ===========================================================================
  #
  # Send subscription calls
  #

  #
  # Show Subscription by Id
  #
  get "#{MYSPACE_URL_BASE}/subscriptions/:id/?$" do
    result, raw_hsh = request_json_safely(:get, "/stream/subscription/#{params[:id]}") do |result, raw_hsh|
      @subscription = Subscription.from_hash raw_hsh['Subscription']
    end
    # @dump = dump_formatted_text result, raw_hsh
    return(haml(:subscription_list)) if (raw_hsh.blank?)
    haml :subscription_show
  end

  #
  # Update Subscription by Id
  #
  get "#{MYSPACE_URL_BASE}/subscriptions/:id/update?$" do
    result, raw_hsh = request_json_safely(:get, "/stream/subscription/#{params[:id]}") do |result, raw_hsh|
      @subscription = Subscription.from_hash raw_hsh['Subscription']
      @subscription.status = 'Active'
    end
    # result, raw_hsh = request_json_safely(:put, "/stream/subscription", @subscription.to_myspace_json)
    # @dump = dump_formatted_text result, raw_hsh
    return(haml(:subscription_list)) if (raw_hsh.blank?)
    haml :subscription_show
  end

  #
  # Delete Subscription by Id
  #
  get "#{MYSPACE_URL_BASE}/subscriptions/:id/delete" do
    subscription_id = params[:id].to_i
    request_json_safely(:delete, "/stream/subscription/#{subscription_id}")
    redirect "#{MYSPACE_URL_BASE}/subscriptions"
  end

  #
  # Create Subscription
  #
  get %{#{MYSPACE_URL_BASE}/subscriptions/create/:obj_type} do
    obj_type = params[:obj_type] || 'note'
    @subscription = Subscription.from_hash(
      :query => { :object => obj_type.to_s.camelize },
      :endpoint => ENDPOINT_PUBLISH_MYSPACE_URL_BASE+"/#{obj_type.to_s.underscore}"
      )
    result, raw_hsh = request_json_safely(:post, "/stream/subscription", @subscription.to_myspace_json) do |result, raw_hsh|
      subscription_url = raw_hsh['statusLink']
      @subscription.id  = subscription_url.gsub(%r{.*/stream/subscription/(\d+)$}, '\1').to_i
    end
    @dump = dump_results_and_stuff result, raw_hsh
    haml :subscription_show
  end

  #
  # List Subscriptions
  #
  get "#{MYSPACE_URL_BASE}/subscriptions/?$" do
    result, raw_hsh = request_json_safely(:get, "/stream/subscription/@all") do |result, raw_hsh|
      @subscriptions = raw_hsh['Subscriptions'].map do |hsh|
        Subscription.from_hash hsh['Subscription']
      end
    end
    # redirect('/') unless raw_hsh
    haml :subscription_list
  end

private
  def request_json_safely(http_method, path, *arguments, &block)
    logger.info session[:flash]
    begin
      result =  @access_token.request(http_method, path, *arguments)
      case result.code.to_i
      when 200, 201
        raw_hsh = JSON.load(result.body) if block
        yield(result, raw_hsh)           if block
        session[:flash][:success] = %Q{Yay #{http_method} subscription: #{h result.message} (#{result.code})} unless http_method == :get
      when 400 # bad request
        session[:flash][:error] = %Q{Can\'t #{http_method} subscription: #{h result['x-opensocial-error']}}
      when 404 # not found
        @dump = dump_results_and_stuff result
        session[:flash][:error] = %Q{Can\'t #{http_method} subscription: #{h result['x-opensocial-error']} (#{h result.message} #{result.code})}
      else
        session[:flash][:error] = %Q{Can\'t #{http_method} subscription: #{h result.message} (#{result.code})}
      end
    rescue JSON::ParserError => e
      session[:flash][:error] = %Q{Error #{e} parsing response #{raw_hsh.inspect} from #{result.body} #{result.to_hash.inspect}. WTF?}
      return
    rescue StandardError => e
      session[:flash][:error] = %Q{Couldn\'t parse response #{raw_hsh.inspect}: #{e}}
      return
    end
    [result, raw_hsh]
  end


  # Filename for stream data -- one chunk for each hour and server
  def output_filename handle
    date     = Time.now.strftime("%Y%m%d")
    datetime = Time.now.strftime("%Y%m%d%H")
    [ WORK_DIR, '/', date, '/', handle,
      '+', datetime,
      '-', HOSTNAME,
      '-', $$,
      '.json' ].join('')
  end

  # Save stream into file
  def process_publication_stream response_iostr
    filename = output_filename("endpoint_myspace-#{params['captures'].first}")
    FileUtils.mkdir_p File.dirname(filename)
    params.delete 'captures'
    text = response_iostr.read + "\n"
    File.open(filename, 'a') do |f|
      f << text
    end
    text
  end

end
