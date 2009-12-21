class Main
  # ===========================================================================
  #
  # Before
  #
  before do
    @title = request.path_info
    session[:flash] ||= {}
    puts "hi"
    logger.info :hi
  end

end
