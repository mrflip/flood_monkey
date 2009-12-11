::ROOT_DIR = File.expand_path(File.dirname(__FILE__)+'/..') unless defined? ::ROOT_DIR
require "dependencies"
require 'monk/glue'
RACK_ENV = 'production' unless defined?(RACK_ENV)

set :application,  Monk::Glue.settings(:app_name)
set :domain,       Monk::Glue.settings(:domain)
set :scm,          :git
set :repository,   "set your repository location here"
set :deploy_via,   :remote_cache

set :user,         "deploy"
set :runner,       user
set :admin_runner, runner
set :deploy_to,    "/slice/www/#{application}" # path to app on remote machine
role :app,         domain
role :web,         domain
role :cpanel,      domain
role :endpoint,    domain


namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C thin/production_config.yml -R thin/config.ru start"
  end

  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C thin/production_config.yml -R thin/config.ru stop"
  end

  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end

  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end
end
