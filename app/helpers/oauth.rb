class Main
  helpers do
    # ===========================================================================
    #
    # OAuth helpers
    #

    # Memoized accessor for the consumer object
    def consumer
      @consumer ||= OAuth::Consumer.new(
        Monk::Glue.settings(:myspace)[:consumer_key],
        Monk::Glue.settings(:myspace)[:consumer_secret],
        Monk::Glue.settings(:myspace)[:oauth_setup]      )
    end

    # Recover the access token from the session, if there is one
    def set_access_token_from_session
      if (session[:access_token] && session[:access_token_secret])
        @access_token = ::OAuth::AccessToken.new(consumer, session[:access_token], session[:access_token_secret])
      end
    end

    # Set the access token directly by using the consumer.
    def set_access_token_from_consumer
      @access_token = OAuth::AccessToken.new consumer
    end

    # clear the request token, save the access token in the session
    def save_access_token_in_session
      session[:request_token]        = nil
      session[:request_token_secret] = nil
      session[:access_token]         = @access_token.token
      session[:access_token_secret]  = @access_token.secret
    end

    # clear the access token, save the request token in the session
    def save_request_token_in_session
      session[:request_token]        = @request_token.token
      session[:request_token_secret] = @request_token.secret
      session[:access_token]         = nil
      session[:access_token_secret]  = nil
    end

  end
end
