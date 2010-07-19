require 'wuclan'
require 'wuclan/twitter'
include Wuclan::Twitter::Model ; include Wuclan::Twitter::Scrape

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
