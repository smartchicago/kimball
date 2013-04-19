set :application, "logan-production"
set :application, "logan"
set :branch, fetch(:branch, "master")

server 'logan.smartchicagoapps.org', :app, :web, :db, :primary => true