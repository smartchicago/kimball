set :application, "logan-production"
set :branch, fetch(:branch, "master")

server 'logan.smartchicagoapps.org', :app, :web, :db, :primary => true