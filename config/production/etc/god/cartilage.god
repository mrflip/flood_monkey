#!/usr/bin/env ruby
# require 'rubygems'
# require 'active_support'
require 'godhead'

# ===========================================================================
#
# Cartilage web app
#
group_options = { :monitor_group => :cartilage, }

# Godhead::NginxRecipe.create group_options.merge({ })
# replace with this one on OSX
Godhead::NginxRunnerRecipe.create group_options.merge({ })

# (5000..5003).each do |port|
#   Godhead::ThinRecipe.create(group_options.merge({
#       :port        => port,
#       :rackup_file => File.join(YUPFRONT_ROOT, 'config.ru'),
#       :runner_conf => File.join(YUPFRONT_ROOT, 'production.yml') }))
# end

gg = Godhead::UnicornRecipe.create  group_options.merge({
    :root_dir => '/slice/www/cartilage/current',
    :pid_file => '/slice/www/cartilage/shared/tmp/unicorn.pid',
    :uid => 'www'
  })
