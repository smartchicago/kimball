require "bundler/capistrano"

set :application, "logan"
set :repository,  "git@github.com:smartchicago/logan.git"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :user, 'logan'

set :branch, 'master'
set :bundle_flags, "--deployment --quiet --binstubs"

server "logan-staging.smartchicagoapps.org", :web, :app, :db

set :default_environment, { 'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH" }

namespace :deploy do
  task :link_db_config do
    # pull in database.yml on server
    run "rm -f #{release_path}/config/database.yml && ln -s #{deploy_to}/shared/database.yml #{release_path}/config/database.yml"
  end
end