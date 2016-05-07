require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'whenever/capistrano'
require 'rvm/capistrano'
require 'rvm/capistrano/gem_install_uninstall'

#loading environment variables so we can all use the same deployment
YAML.load(File.open(File.dirname(__FILE__) + '/local_env.yml')).each do |key, value|
  ENV[key.to_s] = value
  puts ENV[key.to_s]
end if File.exist?(File.dirname(__FILE__) + '/local_env.yml')


set :repository, ENV['GIT_REPOSITORY']

set :scm, :git
set(:deploy_to) { "/var/www/#{application}" }
set :deploy_via, :remote_cache
set :use_sudo, false
set :user, 'logan'

set :stages, %w(production staging)
set :default_stage, 'staging'

set :bundle_flags, '--deployment --quiet'

#set :default_environment, { 'PATH' => '/home/logan/.rbenv/shims:/home/logan/.rbenv/bin:$PATH' }
set :rvm_autolibs_flag, "read-only"       # more info: rvm help autolibs
before 'deploy', 'rvm:install_rvm'  # install/update RVM

ENV['GEM'] = "bundler"
before 'bundle:install', 'rvm:install_gem' # Make sure Bundler is installed for gemset

before 'deploy', 'rvm:install_ruby' # install Ruby and create gemset (both if missing)

set :ssh_options, { forward_agent: true }
# set :shared_children, fetch(:shared_children) + ["sharedconfig"]

before  'deploy:finalize_update', "deploy:create_shared_directories", 'deploy:link_db_config', 'deploy:link_env_var'
# before  'deploy:finalize_update', 'deploy:link_db_config', 'deploy:link_env_var'

after   'deploy:finalize_update', 'deploy:create_binstubs', 'deploy:migrate', 'deploy:generate_delayed_job','deploy:reload_nginx'

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

  task :create_shared_directories do
    run "mkdir -p #{deploy_to}/shared/pids"
    run "mkdir -p #{deploy_to}/shared/system"
    run "mkdir -p #{deploy_to}/shared/assets"
    run "mkdir -p #{deploy_to}/releases"
    run "mkdir -p #{shared_path}/log"
  end

  task :link_db_config do
    # pull in database.yml on server
    run "rm -f #{release_path}/config/database.yml && ln -s #{deploy_to}/shared/database.yml #{release_path}/config/database.yml"
  end

  task :link_env_var do
    # pull in database.yml on server
    run "rm -f #{release_path}/config/local_env.yml && ln -s #{deploy_to}/shared/local_env.yml #{release_path}/config/local_env.yml"
  end

  task :reload_nginx do
    run "service nginx reload"
  end

  # https://github.com/capistrano/capistrano/issues/362#issuecomment-14158487
  namespace :assets do
    task :precompile, roles: assets_role, except: { no_release: true } do
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

  task :generate_delayed_job do
    run "cd #{latest_release.shellescape} && RAILS_ENV=#{rails_env.to_s.shellescape} bundle exec rails generate delayed_job && RAILS_ENV=#{rails_env.to_s.shellescape} bin/delayed_job restart"
  end

end
