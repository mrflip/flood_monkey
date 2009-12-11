WORKDIR = '/slice/www/flood_monkey/shared'
FileUtils.mkdir_p  WORKDIR+'/tmp'
FileUtils.mkdir_p  WORKDIR+'/log'

# 16 workers and 1 master
worker_processes  5
preload_app       true
timeout           80
# listen          8080, :tcp_nopush => true
listen            WORKDIR+'/tmp/unicorn.sock', :backlog => 2048
pid               WORKDIR+'/tmp/unicorn.pid'
stderr_path       WORKDIR+'/log/unicorn.stderr.log'
stderr_path       WORKDIR+'/log/unicorn.stdout.log'

# # REE
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
