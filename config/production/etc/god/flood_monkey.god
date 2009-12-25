require 'godhead'
FLOOD_MONKEY_DEPLOY_DIR = '/var/www/flood_monkey'

# ===========================================================================
#
# Flood_Monkey web app
#
group_options = { :monitor_group => :flood_monkey, }

Godhead::NginxRecipe.create group_options.merge({ })         # Use on systems with /etc/init.d
# Godhead::NginxRunnerRecipe.create group_options.merge({ }) # Use on OSX

Godhead::UnicornRecipe.create     group_options.merge({
    :root_dir => FLOOD_MONKEY_DEPLOY_DIR+'/current',
    :pid_file => FLOOD_MONKEY_DEPLOY_DIR+'/shared/tmp/unicorn.pid',
    :uid      => 'www-data'
  })
