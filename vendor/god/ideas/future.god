# This example shows how you might keep a local development Rails server up
# and running on your Mac.

# Run with:
# god -c /path/to/events.god

RAILS_ROOT = "/Users/tom/dev/helloworld"

God::Contacts::Email.delivery_method = :smtp
God::Contacts::Email.server_settings = {}

God.contact(:email) do |c|
  c.name = 'tom'
  c.email = 'tom@powerset.com'
  c.group = 'developers'
  c.throttle = 30.minutes
end

God.watch do |w|
  w.name = "local-3000"
  w.interval = 5.seconds
  w.start = "mongrel_rails start -P ./log/mongrel.pid -c #{RAILS_ROOT} -d"
  w.stop = "mongrel_rails stop -P ./log/mongrel.pid -c #{RAILS_ROOT}"
  w.pid_file = File.join(RAILS_ROOT, "log/mongrel.pid")
  
  # clean pid files before start if necessary
  w.behavior(:clean_pid_file)
  
  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end
  
  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_exits)
  end
  
  # restart if memory or cpu is too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.interval = 20
      c.above = 50.megabytes
      c.times = [3, 5]
    end
    
    on.condition(:cpu_usage) do |c|
      c.interval = 10
      c.above = 10.percent
      c.times = [3, 5]
    end
  end
  
  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 30.seconds
      c.transition = nil
      c.retry = 60.seconds
      c.giveup_tries = 5
      c.notify = 'tom'
    end
    
    on.condition(:memory_usage) do |c|
      c.interval = 20
      c.above = 40.megabytes
      c.times = [3, 5]
      c.notify = 'tom'
    end
  end
end