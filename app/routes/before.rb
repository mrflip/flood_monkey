class Main
  # ===========================================================================
  #
  # Before
  #
  before do
    @title = request.path_info
    puts session.inspect
    session[:flash] ||= {}
    # puts "hi"
    # logger.info :hi
  end

end
