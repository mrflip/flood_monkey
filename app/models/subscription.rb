Subscription = Struct.new(
  :id,
  :query,
  :rate,
  :batch_size,
  :type,
  :meta_data,
  :format,
  :endpoint,
  :status,
  :remove_list
  )
Subscription.class_eval do
  DEFAULT_PARAMS = {
    :query       => {
      # :location => {:lat => 36.1, :lon => -115.1, :radius => 30},
      :object   => "Music"
    },
    :rate        => 1,
    :batch_size  => 1000,
    :type        => "All",
    :meta_data   => "UserInfo,UserSubscribers,ApplicationData",
    :format      => "application/json",
    :endpoint    => Main.settings(:myspace)[:pub_callback_url],
    :status      => 'Active',
    :remove_list => nil,
  }
  attr_accessor :messages
  cattr_accessor :accessible_attributes
  self.accessible_attributes = [
    :rate, :batch_size, :type, :meta_data, :format, :endpoint, :status,
    :query, :query_as_json
  ]

  def initialize *args
    super *args
    self.fix!
  end

  def self.from_hash hsh={}
    super fix_hash(hsh), true
  end

  def self.from_params params
    subscription = self.from_hash DEFAULT_PARAMS
    params.each do |attr, val|
      subscription.send("#{attr}=", val) if accessible_attributes.include?(attr.to_sym)
    end
    subscription.fix!
    subscription
  end

  def self.fix_hash hsh={}
    hsh = hsh.underscore_keys
    hsh = DEFAULT_PARAMS.deep_merge hsh
  end

  def fix!
    self.batch_size = batch_size.to_i     unless self.batch_size.blank?
    self.rate       = rate.to_i           unless self.rate.blank?
    self.meta_data  = meta_data.join(",") if  (! self.meta_data.blank?) && meta_data.respond_to?(:join)
  end

  def query_as_json
    query.compact.camelize_keys.to_json
  end
  def query_as_json= new_query
    begin
      self.query = JSON.load(new_query).underscore_keys
    rescue JSON::ParserError => e
      self.query = {
        :error => e.to_s,
        :val   => new_query
      }
    end
  end

  def to_myspace_json
    hsh = self.to_hash
    case hsh[:format]
    when :json then hsh[:format] = 'application/json'
    when :xml  then hsh[:format] = 'application/atom+xml'
    end
    { 'Subscription' => hsh.compact.camelize_keys }.to_json
  end

  def self.create hsh
    subscription = Subscription.from_params hsh
    result, raw_hsh, subscription.messages = request_json_safely(:post, "/stream/subscription", subscription.to_myspace_json) do |result, raw_hsh|
      subscription_url = raw_hsh['statusLink']
      subscription.id  = subscription_url.gsub(%r{.*/stream/subscription/(\d+)$}, '\1').to_i
    end
    subscription
  end

  def self.list
    subscriptions = nil
    result, raw_hsh, messages = request_json_safely(:get, "/stream/subscription/@all") do |result, raw_hsh|
      subscriptions = raw_hsh['Subscriptions'].map do |hsh|
        Subscription.from_hash hsh['Subscription']
      end
    end
    [subscriptions, messages]
  end

  def self.get id
    subscription = self.new
    result, raw_hsh, subscription.messages = request_json_safely(:get, "/stream/subscription/#{id}") do |result, raw_hsh|
      subscription.merge! fix_hash(raw_hsh['Subscription'])
    end
    subscription
  end

  def update
    result, raw_hsh, self.messages = self.class.request_json_safely(:put, "/stream/subscription/#{id}", to_myspace_json)
    messages
  end

  def self.get_and_update id, hsh
    # Load the subscription
    subscription = Subscription.get(id)
    return subscription if ! subscription.valid?
    # Update the description
    subscription.merge! hsh
    subscription.update
    subscription
  end

  def self.delete id
    result, raw_hsh, messages = request_json_safely(:delete, "/stream/subscription/#{id}")
    messages
  end
  def delete
    self.class.delete id
  end

  def valid?
    messages.blank? || (! messages[:error])
  end

private
  def self.request_json_safely(http_method, path, *arguments, &block)
    begin
      messages = {}
      raw_hsh  = nil
      result   =  Main.access_token.request(http_method, path, *arguments)
      case result.code.to_i
      when 200, 201
        raw_hsh = JSON.load(result.body) if block
        yield(result, raw_hsh)           if block
        messages[:success] = %Q{Subscription #{http_method} successful : #{result.message} (#{result.code})} # unless http_method == :get
      when 400 # bad request
        messages[:error] = %Q{Can\'t #{http_method} subscription: #{result['x-opensocial-error']}}
      when 404 # not found
        messages[:error] = %Q{Can\'t #{http_method} subscription: #{result['x-opensocial-error']} (#{result.message} #{result.code})}
      else
        messages[:error] = %Q{Can\'t #{http_method} subscription: #{result.message} (#{result.code})}
      end
    rescue JSON::ParserError => e
      messages[:error] = %Q{Error #{e} parsing response #{raw_hsh.inspect} from #{result.body} #{result.to_hash.inspect}. WTF?}
    rescue StandardError => e
      messages[:error] = %Q{Couldn\'t parse response #{raw_hsh.inspect}: #{e}}
    end
    [result, raw_hsh, messages]
  end

end
