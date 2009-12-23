class Main
  helpers do
    include Rack::Utils ;
    alias_method :h, :escape_html

    # simple dumper for a hash like (stuct, list of pairs, whatever)
    def grid_for_hash hsh
      haml_tag :caption, h(hsh.titleize) if hsh.respond_to? :titleize
      hsh.each_pair do |attr, val|
        haml_tag :tr do
          grid_row_for_hash attr, val
        end
      end
    end

    # table row for an attribute-value pair
    def grid_row_for_hash attr, val
      haml_tag(:th, h(attr),         :class => 'attr' )
      haml_tag(:td, h(val.inspect),  :class => 'val'  )
    end

    # debugging helper - inspects given objects in a preformatted block
    def dump_formatted_text *stuff
      '<pre>'+h(stuff.inspect.gsub(/, /, ",\n\t"))+'</pre>'
    end

    # makes an anchor tag.
    def link_to text, path, options={}
      haml_tag(:a, h(text), options.reverse_merge(:href => h(path)))
    end

    # prevents browser caching for an asset using a dummy parameter (the url
    # changes on each call)
    def nocache url
      url + "?t=#{Time.now.utc.to_i}"
    end

  end
end
