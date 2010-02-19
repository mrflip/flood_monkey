class Main
  helpers do
    include Rack::Utils ;
    alias_method :h, :escape_html

    # simple dumper for a hash like (stuct, list of pairs, whatever)
    def grid_for_hash hsh
      hsh.each do |attr, val|
        grid_row_for_hash attr, val
      end
    end

    # table row for an attribute-value pair
    def grid_row_for_hash attr, val
      haml_tag :tr do
        haml_tag(:th, h(attr),         :class => 'attr' )
        haml_tag(:td, h(val.inspect),  :class => 'val'  )
      end
    end

    # debugging helper - inspects given objects in a preformatted block
    def dump_formatted_text *stuff
      '<pre>'+h(stuff.inspect.gsub(/, /, ",\n\t"))+'</pre>'
    end

    # prevents browser caching for an asset using a dummy parameter (the url
    # changes on each call)
    def nocache url
      url + "?t=#{Time.now.utc.to_i}"
    end

  end
end
