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
    run "kill -QUIT \`cat #{deploy_to}/shared/tmp/unicorn.pid\` || true"
  end

  task :restart, :roles => [:web, :app] do
    run "kill -USR2 \`cat #{deploy_to}/shared/tmp/unicorn.pid\` || true"
    sleep 1
    run "kill -QUIT \`cat #{deploy_to}/shared/tmp/unicorn.pid\` || true"
  end

  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end


  task :after_symlink do
    run "ln -nfs #{deploy_to}/shared/system/settings.yml #{deploy_to}/current/config/settings.yml"
  end

  task :after_setup do
    run "sudo gem install rack rack-test sinatra haml extlib monk-glue json unicorn god godhead"
  end

end
