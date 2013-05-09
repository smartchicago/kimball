require "bundler/capistrano"
require "capistrano/ext/multistage"

set :repository,  "git@github.com:smartchicago/kimball.git"

set :scm, :git
set(:deploy_to) { "/var/www/#{application}" }
set :deploy_via, :remote_cache
set :use_sudo, false
set :user, 'logan'

set :stages, ["production", "staging"]
set :default_stage, "staging"

set :bundle_flags, "--deployment --quiet"

set :default_environment, { 'PATH' => "/home/logan/.rbenv/shims:/home/logan/.rbenv/bin:$PATH" }
set :ssh_options, { :forward_agent => true }

before  'deploy:finalize_update', 'deploy:link_db_config'
after   'deploy:finalize_update', 'deploy:create_binstubs'

namespace :deploy do
  task :start do
    run "cd #{current_path} && `./bin/unicorn_rails -c config/unicorn.rb -E #{rails_env.to_s.shellescape} -D`"
  end
  
  task :stop do
    run "cd #{current_path} && kill -TERM `cat tmp/pids/unicorn.pid`"
  end
  
  task :restart do
    # unicorn reloads on USR2
    run "cd #{current_path} && kill -USR2 `cat tmp/pids/unicorn.pid`"
  end
  
  task :link_db_config do
    # pull in database.yml on server
    run "rm -f #{release_path}/config/database.yml && ln -s #{deploy_to}/shared/database.yml #{release_path}/config/database.yml"
  end

  # https://github.com/capistrano/capistrano/issues/362#issuecomment-14158487
  namespace :assets do
    task :precompile, :roles => assets_role, :except => { :no_release => true } do
      run <<-CMD.compact
        cd -- #{latest_release.shellescape} &&
        #{rake} RAILS_ENV=#{rails_env.to_s.shellescape} #{asset_env} assets:precompile
      CMD
    end
  end
  
  # rewrite binstubs
  task :create_binstubs do
    run "cd #{latest_release.shellescape} && bundle binstubs unicorn"
  end
  
end