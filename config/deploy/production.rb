set :application, 'logan-production'
set :branch, fetch(:branch, ENV['PRODUCTION_BRANCH'])
set :rvm_ruby_string, '2.2.4@production'   # use the same ruby as used locally for deployment

server ENV['PRODUCTION_SERVER'], :app, :web, :db, primary: true
