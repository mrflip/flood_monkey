require 'godhead'
FLOOD_MONKEY_DEPLOY_DIR = '/var/www/flood_monkey'

# ===========================================================================
#
# Flood_Monkey web app
#
group_options = { :monitor_group => :flood_monkey, }

# Use NginxRunnerRecipe on OSX
Godhead::NginxRecipe.create group_options.merge({ })
# Godhead::NginxRunnerRecipe.create group_options.merge({ })

Godhead::UnicornRecipe.create     group_options.merge({
    :root_dir => FLOOD_MONKEY_DEPLOY_DIR+'/current',
    :pid_file => FLOOD_MONKEY_DEPLOY_DIR+'/shared/tmp/unicorn.pid',
    :uid      => 'www-data'
  })
