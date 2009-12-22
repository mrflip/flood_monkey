class Main
  # ===========================================================================
  #
  # Before
  #
  before do
    @title = request.path_info
    session[:flash] ||= {}
  end

end
