#!/usr/bin/env ruby
require 'rubygems'
require 'redis'
require 'redis/namespace'
require 'wukong'
require 'wukong/periodic_monitor'
require 'wuclan'
require 'wuclan/twitter'
require 'twitter'
include Wuclan::Twitter::Model ; include Wuclan::Twitter::Scrape
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

TwitterUser.class_eval do
  def fix!
    case
    when scraped_at.is_a?(Time) then self.scraped_at = scraped_at.utc.to_flat
    when (scraped_at.is_a?(String) && (scraped_at !~ /^\d+Z?$/))
      self.scraped_at = DateTime.parse_and_flatten(scraped_at)
    end
    case
    when created_at.respond_to?(:utc) then self.created_at = created_at.utc.to_flat
    when (created_at.is_a?(String) && (created_at !~ /^\d+Z?$/))
      self.created_at = DateTime.parse_and_flatten(created_at)
    end
  end
end

TwitterUserId.class_eval do
  def scrape_weight force=nil
    case
    when force                   then -1e9
    when (scraped_at.to_i != 0) then scraped_at.to_i
    when (user_id.to_i    != 0) then (user_id.to_i - 1e9)
    else -rand(1000) end
  end

  def protected?
    protected.to_i != 0
  end
end

class UsersLoader < Wukong::Streamer::StructStreamer
  def initialize *args
    super *args
    @monitor = PeriodicMonitor.new options
  end
  def redis
    @redis ||= Redis::Namespace.new(:tw, :redis => Redis.new())
  end

  def twitter
    return @twitter if @twitter
    oauth = Twitter::OAuth.new( Settings['token'], Settings['secret'])
    oauth.authorize_from_access(Settings['atoken'], Settings['asecret'])
    @twitter = Twitter::Base.new(oauth)
  end

  def register_for_scrape user
    return if user.protected? || user.screen_name.blank?
    redis.zadd "u:sc_sn", user.scrape_weight, user.screen_name
  end

  def process user, *_
    register_for_scrape user
    @monitor.periodically{|iter| Log.info [redis.zcard('u:sc_sn'), iter, Time.now.to_flat, user.to_flat].join("\t") }
  end

  def reflect_user nbrs
    maybes = Set.new
    nbrs.each do |u|
      next if u.followers_count > 500
      return u if (u.followers_count >= 90) && (u.followers_count % 100 > 90)
      maybes << u
    end
    maybes.sort_by{|u| -u.followers_count }.first
  end

  def each_request
    3.times do |iter|
      offset = iter*10
      batch = redis.zrange('u:sc_sn', offset+0, offset+9)
      friends_resp = twitter.friends(:screen_name => batch.first, :count => 100, :cursor => -1)
      friends = friends_resp['users']
      refl_u  = reflect_user(friends)
      refl_uu = TwitterUser.from_hash(refl_u) ; refl_uu.scraped_at ||= Time.now ; refl_uu.fix!
      if refl_u.followers_count > 90 then p refl_uu.to_flat
      end
      p friends_resp.values_of("previous_cursor", "previous_cursor_str", "next_cursor", "next_cursor_str")
      fc = friends.map do |fr|
        fr.followers_count.to_i rescue nil
      end.compact
      puts fc.join("\t")
      # puts friends.first.to_hash.inspect
      uu =  TwitterUser.from_hash(friends.first.merge('scraped_at' => Time.now)) ; uu.fix!
      puts uu.to_flat.join("\t")
    end
  end

  def after_stream
    each_request
  end
end

Wukong::Script.new(UsersLoader, nil
  ).run

# 100 tw * 10_000_000 => 1B
