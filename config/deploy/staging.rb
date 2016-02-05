set :application, 'logan-staging'
set :branch, fetch(:branch, 'development')
set :rails_env, :staging

server ENV['STAGING_SERVER'], :app, :web, :db, primary: true

task :link_env_var do
  # pull in database.yml on server
  run "rm -f #{release_path}/config/local_env.yml && ln -s #{deploy_to}/shared/local_env.yml #{release_path}/config/local_env.yml"
end
