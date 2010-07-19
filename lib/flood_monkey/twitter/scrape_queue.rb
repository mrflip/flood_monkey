require 'redis'
require 'redis/namespace'

Settings.define :scrape_queue, :default => 'sc_sn', :description => 'name of the redis ZSET holding the scrape queue'

#
# Pull the scrape ticket with most priority
# Fetch it
# Store results
# do monitoring
# repeat
#
class ScrapeQueue
  cattr_accessor :queue
  self.queue = Settings.queue
  def initialize *args
    @monitor = PeriodicMonitor.new options
  end
  def redis
    @redis ||= Redis::Namespace.new(:tw, :redis => Redis.new())
  end

  #
  # Handle each record in turn:
  # * Pull the scrape ticket with most priority
  # * Process it
  # * do monitoring
  # * repeat!
  # 
  def run!
    loop do
      process next_record
      @monitor.periodically{|i| i }
      break if empty?
    end    
  end

  # Process the job
  def process
    raise
  end

  #
  # queue operations
  #
  
  def <<(item)
    raise
  end

  def next_record
    raise
  end

  def size
    redis.zcard(queue)
  end

  def empty?
    size == 0
  end
end
