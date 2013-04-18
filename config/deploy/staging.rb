set :application, "logan-staging"
set :branch, 'development'
set :rails_env, :staging

server 'logan-staging.smartchicagoapps.org', :app, :web, :db, :primary => true