class EndpointResponder
  def initialize(app)
    @app = app
  end

  def call(env)
    @path_info = Rack::Utils.unescape(env["PATH_INFO"])
    p [@path_info, "EndpointResponder Path"]
    if @path_info =~ %r{/endpoint/foo}
      body = Rack::Utils.unescape(env['rack.input'].read).gsub(/[\t\n]/," ")
      puts body
      [200, {"Content-Type" => "text/plain",
          "Content-Length" => body.size.to_s }, body[0..1000]]
    else
      @app.call(env)
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


  # Filename for stream data -- one chunk for each hour and server
  def output_filename handle
    date     = Time.now.strftime("%Y%m%d")
    datetime = Time.now.strftime("%Y%m%d%H")
    [ WORK_DIR, '/', date, '/', handle,
      '+', datetime,
      '-', HOSTNAME,
      '-', $$,
      '.xml' ].join('')
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
