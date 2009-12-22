UNICORN_DIR = '/var/www/flood_monkey/shared'
FileUtils.mkdir_p  UNICORN_DIR+'/tmp'
FileUtils.mkdir_p  UNICORN_DIR+'/log'

case ENV['RACK_ENV']
when 'development'
  worker_processes  2
  preload_app       false
else
  worker_processes  10
  preload_app       true
end

timeout             80
# listen            8000, :tcp_nopush => true
listen              UNICORN_DIR+'/tmp/unicorn.sock', :backlog => 2048
pid                 UNICORN_DIR+'/tmp/unicorn.pid'
stderr_path         UNICORN_DIR+'/log/unicorn.stderr.log'
stderr_path         UNICORN_DIR+'/log/unicorn.stdout.log'

# # REE
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
