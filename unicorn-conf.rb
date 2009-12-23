app_dir = '/var/www/flood_monkey'
FileUtils.mkdir_p  app_dir+'/shared/tmp'
FileUtils.mkdir_p  app_dir+'/shared/log'

timeout             80
# listen            8000, :tcp_nopush => true
working_directory   app_dir+'/current'
listen              app_dir+'/shared/tmp/unicorn.sock', :backlog => 2048
pid                 app_dir+'/shared/tmp/unicorn.pid'

case ENV['RACK_ENV']
when 'development'
  worker_processes  2
  preload_app       false
else
  worker_processes  5
  preload_app       true
  stderr_path         app_dir+'/shared/log/unicorn.stderr.log'
  stderr_path         app_dir+'/shared/log/unicorn.stdout.log'
end

# # REE
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
