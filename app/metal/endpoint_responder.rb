class EndpointResponder
  def initialize(app)
    @app = app
  end

  # If it's a POST to the publish path, process the post body
  # Otherwise pass it up the chain.
  def call(env)
    @path_info = Rack::Utils.unescape(env["PATH_INFO"])
    if (env["REQUEST_METHOD"]=='POST') && (@path_info =~ %r{\A#{MYSPACE_PUB_BASE}/(\w+)\z})
      slug = $1
      text  = process_publication_stream env['rack.input'], slug
      response_body = ['OK', text.size, Time.now.utc, slug].join("\t")
      [ 200,
        {"Content-Type" => "text/plain", "Content-Length" => response_body.size.to_s },
        response_body ]
    else
      @app.call(env)
    end
  end

  # Unencodes and sanitizes the request body text
  def extract_text response_iostr
    Rack::Utils.unescape(response_iostr.read).gsub(/[\t\n]/," ")+"\n"
  end

  # Save stream into file
  def process_publication_stream response_iostr, slug
    text = extract_text(response_iostr)
    dump_file(slug) do |f|
      f << text
    end
    text
  end

  # File to dump
  def dump_file slug, &block
    filename = output_filename slug
    FileUtils.mkdir_p File.dirname(filename)
    File.open(filename, 'a'){|f| block.call f }
  end

  # Filename for stream data -- one chunk for each hour and server
  def output_filename slug
    date     = Time.now.strftime("%Y%m%d")
    datetime = Time.now.strftime("%Y%m%d%H")
    [ WORK_DIR, '/', date, '/',
      "endpoint_myspace",
      '-', slug,
      '+', datetime,
      '-', HOSTNAME,
      '-', $$,        # pid
      '.xml' ].join('')
  end
end
