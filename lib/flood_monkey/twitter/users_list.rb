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

Wukong::Script.new(UsersLoader, nil
  ).run

class UsersScraper < ScrapeQueue

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

  def reflect_user nbrs
    maybes = Set.new
    nbrs.each do |u|
      next if u.followers_count > 500
      return u if (u.followers_count >= 90) && (u.followers_count % 100 > 90)
      maybes << u
    end
    maybes.sort_by{|u| -u.followers_count }.first
  end

  def fetch_user_timeline
    # http://dev.twitter.com/doc/get/statuses/user_timeline
    timeline = twitter.user_timeline( :screen_name => sn,
      :count => 200, :page => 1, :include_entities => true, :include_rts => false, :skip_user => true)
  end

  def each_request
    3.times do |iter|
      offset = iter*10
      batch = redis.zrange('u:sc_sn', offset+0, offset+9)
      sn = batch.first

      # friends_resp = twitter.friends(:screen_name => batch.first, :count => 100, :cursor => -1)
      # friends = friends_resp['users']
      # refl_u  = reflect_user(friends)
      # refl_uu = TwitterUser.from_hash(refl_u) ; refl_uu.scraped_at ||= Time.now ; refl_uu.fix!
      # if refl_u.followers_count > 90 then p refl_uu.to_flat
      # end
      # p friends_resp.values_of("previous_cursor", "previous_cursor_str", "next_cursor", "next_cursor_str")
      # fc = friends.map do |fr|
      #   fr.followers_count.to_i rescue nil
      # end.compact
      # puts fc.join("\t")
      # # puts friends.first.to_hash.inspect
      # uu =  TwitterUser.from_hash(friends.first.merge('scraped_at' => Time.now)) ; uu.fix!
      # puts uu.to_flat.join("\t")
    end
  end
end
