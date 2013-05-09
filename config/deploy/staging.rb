set :application, "logan-staging"
set :branch, fetch(:branch, "development")
set :rails_env, :staging

server 'patterns-staging.smartchicagoapps.org', :app, :web, :db, :primary => true