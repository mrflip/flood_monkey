ROOT_DIR = '/var/www/flood_monkey/shared'
FileUtils.mkdir_p  ROOT_DIR+'/tmp'
FileUtils.mkdir_p  ROOT_DIR+'/log'

# 16 workers and 1 master
worker_processes  5
preload_app       true
timeout           80
# listen          8080, :tcp_nopush => true
listen            ROOT_DIR+'/tmp/unicorn.sock', :backlog => 2048
pid               ROOT_DIR+'/tmp/unicorn.pid'
stderr_path       ROOT_DIR+'/log/unicorn.stderr.log'
stderr_path       ROOT_DIR+'/log/unicorn.stdout.log'

# # REE
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
