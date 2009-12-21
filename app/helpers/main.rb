class Main
  helpers do

    include Rack::Utils ;
    alias_method :h, :escape_html

    # Your helpers go here. You can also create another file in app/helpers with the same format.
    # All helpers defined here will be available across all the application.
    #
    # @example A helper method for date formatting.
    #
    #   def format_date(date, format = "%d/%m/%Y")
    #     date.strftime(format)
    #   end


    def dump_formatted_text *stuff
      '<pre>'+h(stuff.inspect.gsub(/, /, ",\n\t"))+'</pre>'
    end

    def dump_results_and_stuff result, *stuff
      dump_formatted_text "access token", @access_token, "result.body", result.body, "result.to_hash", result.to_hash, "also", *stuff
    end


    def longass_debug_string subscription, result
      [ "<pre>",
        h(REQUESTED_URLS),
        "Access Token object",
        h(@access_token.inspect.gsub(/, /, ",\n\t\t").gsub(/@secret="[^"]+"/, "SECRET")),
        "Session",
        "\t"+h(session.to_hash.inspect.gsub(/, /, ",\n\t\t")),
        "Result Body from myspace server",
        "\t"+h(result.body),
        "Result Header from myspace server",
        "\t"+h(result.header.to_hash.inspect.gsub(/, /, ",\n\t\t")),
        "</pre>"].join("\n")
    end



    def bool_cell attr, val, tag=:div
      haml_tag(tag, h(attr))
      haml_tag(tag, (val ? 'YES' : 'NO'), :class => "bool #{(val ? 'on' : 'off')}" )
    end
    def kv_cell attr, val, tag=nil
      tag ||= :div
      haml_tag(tag, h(attr), :class => 'attr' )
      haml_tag(tag, h(val),  :class => 'val'  )
    end

    def grid_for_hash hsh, sort=nil
      hsh = hsh.sort if sort
      hsh.each do |attr,val|
        haml_tag :tr do
          kv_cell attr, val.inspect, :td
        end
      end
    end

    def link_to text, path
      %Q{<a href="#{path}">#{h text}</a>}
    end

    # for an asset tag: don't cache
    def nocache url
      url + "?t=#{Time.now.utc.to_i}"
    end

  end
end
