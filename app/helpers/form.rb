class Main
  helpers do

    # Another take on http://github.com/twilson63/sinatra-formhelpers/raw/master/lib/sinatra/formhelpers.rb
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

    def dl_dt_text_field obj, field, options={ }, &block
      haml_tag(:dt){ label(obj, field) }
      haml_tag(:dd) do
        inline_help = options.delete(:inline_help)
        text_field(obj, field, options)
        if block
          help_div_class = inline_help ? 'inline help' : 'help'
          haml_tag(:div, { :class => help_div_class }){ yield }
        end
      end
    end

    def labeled_field obj, field, options={ }, &block
      haml_tag(:dt){ label(obj, field) }
      haml_tag(:dd) do
        yield if block
      end
    end

    def label(obj, field, display = "", options={})
      haml_tag :label, display.blank? ? field.to_s.humanize : display, options.merge(:for => form_obj_id(obj, field))
    end

    def text_field(obj, field="", options={})
      content = value_of(obj, field)
      options = options.reverse_merge({ :type => "text", :value => content,
          :name => form_obj_name(obj, field), :id => form_obj_id(obj, field) })
      haml_tag :input, '', options
    end

    def text_area(obj, field="", options={})
      content = value_of(obj, field)
      options = options.reverse_merge({ :type => "text",
          :name => form_obj_name(obj, field), :id => form_obj_id(obj, field) })
      haml_tag :textarea, h(content), options
    end

    def submit_button value="Submit", options={}
      haml_tag :input, '', options.reverse_merge({ :type => "submit", :value => value }.compact)
    end

    def checkbox_group obj, field, collection, options={}
      collection.each do |value|
        haml_tag :input, options.reverse_merge({ :type => "checkbox", :value => value,
            :name    => form_obj_name(obj, field.to_s)+"[]",
            :checked => obj.send(field).include?(value.to_s),
            :id      => form_obj_id(obj, "#{field}_#{value}") }.compact)
        label obj, "#{field}_#{value}", value.to_s.underscore.to_s.humanize
      end
    end

    def checkbox obj, field, value, options={}
      options = options.merge(:checked => true) if obj.send(field).to_s == value.to_s
      haml_tag :input, options.reverse_merge(:type => "hidden", :value => '0',
        :name => form_obj_name(obj, field) )
      haml_tag :input, options.reverse_merge(:type => "checkbox", :value => value,
        :name => form_obj_name(obj, field), :id => form_obj_id(obj, field) )
      label obj, field, value
    end

    def is_selected obj, field, value
      { :selected => (obj.send(field).to_s == value.to_s) }.compact
    end
    def collection_select obj, field, collection, value_method=nil, text_method=nil, options = {}
      haml_tag :select, { :name => form_obj_name(obj, field), :id => form_obj_id(obj, field) } do
        collection_texts_and_values(collection, value_method, text_method) do |value, text|
          haml_concat h([options, is_selected(obj, field, value), obj.send(field), obj].inspect)
          opt_options = is_selected(obj, field, value)
          haml_tag :option, h(text), opt_options.merge(:value => h(value))
        end
      end
    end

    # def image_tag(src, options={})
    #   haml_tag :img, options.merge(:src => src)
    # end
    #
    #
    # def radio(obj, field, value, options={})
    #   #content = @params[obj] && @params[obj][field.to_s] == value ? "true" : ""
    #   # , :checked => content
    #   tag :input, "", options.merge(:type => "radio", :id => "#{obj}_#{field}_#{value}", :name => "#{obj}[#{field}]", :value => value)
    # end
    #
    # def hidden(obj, field="", options={})
    #   content = @params[obj] && @params[obj][field.to_s] == value ? "true" : ""
    #   single_tag :input, options.merge(:type => "hidden", :id => "#{obj}_#{field}", :name => "#{obj}[#{field}]")
    # end

  private

    def form_obj_id obj, field
      name = case obj
             when String, Symbol then obj.to_s
             else obj.class.to_s.underscore
             end
      "#{name}_#{field}"
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

    def collection_texts_and_values collection, value_method=nil, text_method=nil, &block
      return collection            if String === collection
      collection = collection.to_a if Hash   === collection
      if value_method
        collection.each do |row|
          yield row.send(value_method), row.send(text_method)
        end
      else
        collection.each do |value, text|
          text ||= value
          yield value, text
        end
      end
    end

  end
end
