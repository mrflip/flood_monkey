class Main
  # ===========================================================================
  #
  # Before Filters
  #
  before do
    @title = request.path_info
    protected! if (request.path_info =~ %r{\A#{MYSPACE_URL_BASE}/subscriptions})
  end
end
