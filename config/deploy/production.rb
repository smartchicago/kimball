set :application, "logan-production"
set :branch, fetch(:branch, "master")

server 'patterns.smartchicagoapps.org', :app, :web, :db, :primary => true