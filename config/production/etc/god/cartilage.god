require 'godhead'
CARTILAGE_DEPLOY_DIR = '/var/www/cartilage'

# ===========================================================================
#
# Cartilage web app
#
group_options = { :monitor_group => :cartilage, }

# Use NginxRunnerRecipe on OSX
Godhead::NginxRecipe.create group_options.merge({ })
# Godhead::NginxRunnerRecipe.create group_options.merge({ })

Godhead::UnicornRecipe.create     group_options.merge({
    :root_dir => CARTILAGE_DEPLOY_DIR+'/current',
    :pid_file => CARTILAGE_DEPLOY_DIR+'/shared/tmp/unicorn.pid',
    :uid      => 'www-data'
  })
