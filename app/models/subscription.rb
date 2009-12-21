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
    :rate        => 100,
    :batch_size  => 1000,
    :type        => "All",
    :meta_data   => "UserInfo,UserSubscribers,ApplicationData",
    :format      => "application/json",
    :endpoint    => Monk::Glue.settings(:myspace)[:callback_url],
    :status      => nil,
    :remove_list => nil,
  }
  def self.from_hash hsh={}
    hsh = hsh.underscore_keys
    hsh = DEFAULT_PARAMS.deep_merge hsh
    super hsh, true
  end

  def to_myspace_json
    hsh = self.to_hash
    case hsh[:format]
    when :json then hsh[:format] = 'application/json'
    when :xml  then hsh[:format] = 'application/atom+xml'
    end
    { 'Subscription' => hsh.compact.camelize_keys }.to_json
  end

end
