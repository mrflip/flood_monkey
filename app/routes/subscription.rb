#
# Myspace Subscription Management
#
class Main
  #
  # New subscription
  #
  get "#{MYSPACE_URL_BASE}/subscriptions/new/?$" do
    @subscription = Subscription.from_hash :foo => 'bar'
    haml :subscription_new
  end

  #
  # Edit subscription
  #
  get "#{MYSPACE_URL_BASE}/subscriptions/:id/edit/?$" do
    @subscription = Subscription.get(params[:id])
    set_flash @subscription.messages
    if @subscription.valid? then haml(:subscription_edit) else haml(:subscription_list) end
  end

  #
  #
  # Update Subscription by Id
  #
  def update_subscription hsh
    @subscription = Subscription.get_and_update params[:id], hsh
    set_flash @subscription.messages
    if @subscription.valid? then haml(:subscription_show) else haml(:subscription_list) end
  end

  def create_subscription hsh
    @subscription = Subscription.create hsh
    set_flash @subscription.messages
      @dump = [@subscription, params].inspect
    if @subscription.valid? then
      haml(:subscription_show)
    else
      haml(:subscription_list)
    end
  end

  # Update Subscription from form
  get "#{MYSPACE_URL_BASE}/subscriptions/:id/update?$" do
    update_subscription params
  end

  # Update Subscription from form
  put "#{MYSPACE_URL_BASE}/subscriptions/:id/?$" do
    update_subscription params[:subscription]
  end

  #
  # Default Subscription
  #
  get %{#{MYSPACE_URL_BASE}/subscriptions/create/:obj_type} do
    obj_type = params[:obj_type] || 'note'
    create_subscription(
      :query => { :object => obj_type.to_s.camelize },
      :endpoint => settings(:myspace)[:pub_callback_url] # + "/#{obj_type.to_s.underscore}"
      )
  end

  # Reactivate subscription when it's been disabled
  get "#{MYSPACE_URL_BASE}/subscriptions/:id/reactivate?$" do
    update_subscription :status => 'Active'
  end

  #
  # Show Subscription by Id
  #
  get "#{MYSPACE_URL_BASE}/subscriptions/:id/?$" do
    @subscription = Subscription.get(params[:id])
    set_flash @subscription.messages
    if @subscription.valid? then haml(:subscription_show) else haml(:subscription_list) end
  end

  post "#{MYSPACE_URL_BASE}/subscriptions" do
    create_subscription params[:subscription]
    #h [params, Subscription.from_params(params['subscription'])].inspect
  end

  #
  # Delete Subscription by Id
  #
  get "#{MYSPACE_URL_BASE}/subscriptions/:id/delete" do
    messages = Subscription.delete(params[:id])
    set_flash messages
    redirect "#{MYSPACE_URL_BASE}/subscriptions"
  end

  #
  # List Subscriptions
  #
  get "#{MYSPACE_URL_BASE}/subscriptions/?$" do
    @subscriptions, messages = Subscription.list
    set_flash messages
    if messages[:error].blank? then
      haml(:subscription_list) else redirect(MYSPACE_URL_BASE) end
  end
end
