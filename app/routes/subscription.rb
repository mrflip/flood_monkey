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
    set_flash @subscription.messages, :now
    if @subscription.valid? then haml(:subscription_edit) else haml(:subscription_list) end
  end

  #
  #
  # Update Subscription by Id
  #
  def update_subscription hsh
    @subscription = Subscription.get_and_update params[:id], hsh
    set_flash @subscription.messages, :now
    if @subscription.valid? then haml(:subscription_show) else haml(:subscription_list) end
  end

  # Update Subscription from form
  get "#{MYSPACE_URL_BASE}/subscriptions/:id/update?$" do
    update_subscription params
  end

  # Update Subscription from form
  put "#{MYSPACE_URL_BASE}/subscriptions/:id/?$" do
    update_subscription params[:subscription]
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
    set_flash @subscription.messages, :now
    if @subscription.valid? then haml(:subscription_show) else haml(:subscription_list) end
  end

  #
  # Create subscription
  #
  def create_subscription hsh
    @subscription = Subscription.create hsh
    if @subscription.valid? then
      set_flash @subscription.messages
      redirect "#{MYSPACE_URL_BASE}/subscriptions/#{@subscription.id}"
    else
      set_flash @subscription.messages, :now
      haml(:root)
    end
  end

  #
  # Create New Subscription From Defaults
  #
  get %{#{MYSPACE_URL_BASE}/subscriptions/create/:obj_type} do
    obj_type = params[:obj_type].to_s
    create_subscription(
      :query    => { :object => obj_type.camelize },
      :endpoint => Main.myspace_pub_callback(obj_type.underscore)
      )
  end

  #
  # Create New Subscription
  #
  post "#{MYSPACE_URL_BASE}/subscriptions" do
    create_subscription params[:subscription]
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
    if messages[:error].blank?
      flash.now[:notice] = "No current subscriptions. Want to make one?" if @subscriptions.blank?
      set_flash messages, :now
      haml(:subscription_list)
    else
      set_flash messages
      redirect(MYSPACE_URL_BASE)
    end
  end
end
