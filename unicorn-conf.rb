app_dir = '/var/www/flood_monkey'
FileUtils.mkdir_p  app_dir+'/shared/tmp'
FileUtils.mkdir_p  app_dir+'/shared/log'

case ENV['RACK_ENV']
when 'development'
  worker_processes  2
  preload_app       false
else
  worker_processes  5
  preload_app       true
  stderr_path       app_dir+'/shared/log/unicorn.stderr.log'
  stdout_path       app_dir+'/shared/log/unicorn.stdout.log'
end

# # REE
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

timeout             80
working_directory   app_dir+'/current'
listen              app_dir+'/shared/tmp/unicorn.sock', :backlog => 64
pid                 app_dir+'/shared/tmp/unicorn.pid'

after_fork do |server, worker|
  # per-process listener ports for debugging/admin/migrations
  addr = "127.0.0.1:#{9000 + worker.nr}"
  # keep trying to connect to port, wait 5s in between (an older daemon might
  # still be quitting and won the port).
  server.listen(addr, :tries => -1, :delay => 5, :backlog => 64)  # , :tcp_nopush => true
end
