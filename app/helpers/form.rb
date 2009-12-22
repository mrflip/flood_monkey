class Main
  # helpers do

    # From http://github.com/twilson63/sinatra-formhelpers/raw/master/lib/sinatra/formhelpers.rb
    #
    # FormHelpers are a suite of helper methods
    # built to make building forms in Sinatra
    # a breeze.
    #
    # link "jackhq", "http://www.jackhq.com"
    #
    # label :person, :first_name
    # text :person, :first_name
    #
    # area :person, :notes
    #
    # etc.

    def link(content, href, options={})
      tag :a, content, options.merge(:href => href)
    end

    def form_obj_id obj, field
      name = case obj
             when String, Symbol then obj.to_s
             else obj.class.to_s.underscore
             end
      "#{name}_#{field}"
    end

    def dl_dt_text_field obj, field, options={ }
      haml_tag(:dt){ label(obj, field) }
      haml_tag(:dd){ text_field(obj, field, options) }
    end

    def form_obj_name obj, field
      name = case obj
             when String, Symbol then obj.to_s
             else obj.class.to_s.underscore
             end
      "#{name}[#{field}]"
    end

    def value_of obj, field
      obj.respond_to?(field) ? obj.send(field).to_s : ""
    end

    def label(obj, field, display = "", options={})
      haml_tag :label, display.blank? ? field.to_s.humanize : display, options.merge(:for => form_obj_id(obj, field))
    end

    def text_field(obj, field="", options={})
      content = value_of(obj, field)
      options = options.reverse_merge({ :type => "text", :value => content,
        :id => form_obj_id(obj, field), :name => form_obj_name(obj, field) })
      haml_tag :input, '', options
    end

    def text_area(obj, field="", options={})
      content = value_of(obj, field)
      options = options.reverse_merge({ :type => "text",
        :id => form_obj_id(obj, field), :name => form_obj_name(obj, field) })
      haml_tag :textarea, h(content), options
    end

    def submit_button value="Submit", options={}
      haml_tag :input, '', options.reverse_merge({ :type => "submit", :value => value }.compact)
    end

    def image_tag(src, options={})
      haml_tag :img, options.merge(:src => src)
    end

    def checkbox(obj, field, options={})
      single_tag :input, options.merge(:type => "checkbox", :id => "#{obj}_#{field}", :name => "#{obj}[#{field}]")

    end

    def radio(obj, field, value, options={})
      #content = @params[obj] && @params[obj][field.to_s] == value ? "true" : ""
      # , :checked => content
      tag :input, "", options.merge(:type => "radio", :id => "#{obj}_#{field}_#{value}", :name => "#{obj}[#{field}]", :value => value)
    end

    def select(obj, field, items, options={})
      content = ""
      items.each do |i|
        content = content + tag(:option, i, { :value => i })
      end
      tag :select, content, options
    end

    def hidden(obj, field="", options={})
      content = @params[obj] && @params[obj][field.to_s] == value ? "true" : ""
      single_tag :input, options.merge(:type => "hidden", :id => "#{obj}_#{field}", :name => "#{obj}[#{field}]")
    end

    # standard open and close tags
    # EX : tag :h1, "shizam", :title => "shizam"
    # => <h1 title="shizam">shizam</h1>
    def tag(name,content,options={})
      with_opts = "<#{name.to_s} #{options.to_html_attrs}>#{content}</#{name}>"
      no_opts = "<#{name.to_s}>#{content}</#{name}>"
      haml_tag( options.blank? ? no_opts : with_opts )
    end

    # standard single closing tags
    # single_tag :img, :src => "images/google.jpg"
    # => <img src="images/google.jpg" />
    def single_tag(name,options={})
      haml_concat "<#{name.to_s} #{options.to_html_attrs} />"
    end

  # end
end

class Hash
  def to_html_attrs
    html_attrs = ""
    self.each do |key, val|
      html_attrs << "#{key}='#{val}' "
    end
    html_attrs.chop
  end
end
