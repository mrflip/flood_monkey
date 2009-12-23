class Main
  helpers do
    def protected!
      response['WWW-Authenticate'] = %(Basic realm="Log in to manage subscriptions") and \
      throw(:halt, [401, "Not authorized\n"]) and \
      return unless authorized?
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? &&
        @auth.basic? &&
        (! @auth.credentials.blank?) &&
        @auth.credentials == [settings(:basic_auth)[:username], settings(:basic_auth)[:password]]
    end
  end
end
