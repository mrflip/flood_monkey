::ROOT_DIR = File.expand_path(File.dirname(__FILE__)+'/..') unless defined? ::ROOT_DIR
require "dependencies"
require 'monk/glue'
RACK_ENV = 'production' unless defined?(RACK_ENV)

set :application,  Monk::Glue.settings(:app_name)
set :domain,       Monk::Glue.settings(:domain)
set :repository,   Monk::Glue.settings(:repository)
set :scm,          :git
set :deploy_via,   :remote_cache

set :user,         "deploy"
set :runner,       user
set :admin_runner, runner
set :deploy_to,    "/var/www/#{application}" # path to app on remote machine
role :app,         domain
role :web,         domain
role :cpanel,      domain
role :endpoint,    domain

namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && unicorn -D -c unicorn-conf.rb config.ru"
  end

  task :stop, :roles => [:web, :app] do
    run "kill \`cat #{deploy_to}/shared/tmp/unicorn.pid\` || true"
  end

  task :restart, :roles => [:web, :app] do
    run(%Q{ if [ -f #{deploy_to}/shared/tmp/unicorn.pid ] ; } +
      %Q{ then kill -USR2 \`cat #{deploy_to}/shared/tmp/unicorn.pid\` ; sleep 1 ; kill -QUIT \`cat #{deploy_to}/shared/tmp/unicorn.pid\` ; } +
      %Q{ else cd #{deploy_to}/current && unicorn -D -c unicorn-conf.rb config.ru ; fi })
  end

  task :after_symlink do
    run "ln -nfs #{deploy_to}/shared/system/settings.yml #{deploy_to}/current/config/settings.yml"
  end

  task :after_setup do
    run "sudo gem install rack rack-test sinatra haml extlib monk-glue json unicorn god godhead"
  end

  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end
end


# cap deploy               # Deploys your project.
# cap deploy:check         # Test deployment dependencies.
# cap deploy:cleanup       # Clean up old releases.
# cap deploy:cold          # Deploys and starts a `cold' application.
# cap deploy:pending       # Displays the commits since your last deploy.
# cap deploy:pending:diff  # Displays the `diff' since your last deploy.
# cap deploy:rollback      # Rolls back to a previous version and restarts.
# cap deploy:rollback:code # Rolls back to the previously deployed version.
# cap deploy:setup         # Prepares one or more servers for deployment.
# cap deploy:symlink       # Updates the symlink to the most recently deployed ...
# cap deploy:update        # Copies your project and updates the symlink.
# cap deploy:update_code   # Copies your project to the remote servers.
# cap deploy:upload        # Copy files to the currently deployed version.
# cap invoke               # Invoke a single command on the remote servers.
# cap shell                # Begin an interactive Capistrano session.
