#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wukong/periodic_monitor'
require 'twitter'
require 'configliere'
Configliere.use :commandline, :config_file
Settings.read('twitter.yaml')
Settings.resolve!


#
# * register your app on dev.twitter.com
# ** make sure it's a 'desktop' app
# * run
#       ruby -rubygems /path/to/rubygems/twitter-0.9.8/examples/connect.rb
#
# * open the url it puts.
# * auth your app. it will give you a PIN -- don't know what to do with this.
# * visit dev.infochimps.org again.


# require File.join(File.dirname(__FILE__), '..', 'lib', 'twitter')
# require File.join(File.dirname(__FILE__), 'helpers', 'config_store')
# require 'pp'
#
# config = ConfigStore.new("#{ENV['HOME']}/.twitter")
#
class ScrapeQueueLoader < Wukong::Streamer::StructStreamer
  def process user, *_
    register_for_scrape user
    @monitor.periodically{|iter| Log.info [redis.zcard('u:sc_sn'), iter, Time.now.to_flat, user.to_flat].join("\t") }
  end
end

Wukong::Script.new(UsersLoader, nil
  ).run
