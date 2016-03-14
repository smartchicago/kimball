set :application, 'logan-production'
set :branch, fetch(:branch, 'master')
set :rvm_ruby_string, '2.2.4@production'   # use the same ruby as used locally for deployment

server 'patterns.smartchicagoapps.org', :app, :web, :db, primary: true
