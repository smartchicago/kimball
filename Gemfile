source 'https://rubygems.org'
ruby '2.2.9'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.10'

# gem 'pg' # soooooon!
# must use this version of mysql2 for rails 4.0.0
gem 'mysql2'

gem 'redis' # ephemeral storage. used for expiring wit.ai contexts

gem 'validates_overlap' # to ensure we don't double book people

gem 'rails_12factor'

gem 'mail', '2.6.3'

gem 'ransack', github: 'activerecord-hackery/ransack'


group :development do
  # gem 'capistrano'
  # mainline cap is busted w/r/t Rails 4. Try this fork instead.
  # src: https://github.com/capistrano/capistrano/pull/412
  gem 'capistrano', git: 'git://github.com/capistrano/capistrano.git', tag: 'v2.15.4'
  gem 'rvm-capistrano', require: false
  # this whole group makes finding performance issues much friendlier
  gem 'rack-mini-profiler'
  gem 'flamegraph'
  gem 'stackprof' # ruby 2.1+ only
  gem 'memory_profiler'
  gem 'ruby-prof'

  # n+1 killer.
  gem 'bullet'

  # what attributes does this model actually have?
  gem 'annotate'

  # a console in your tests, to find out what's actually happening
  gem 'pry-rails'

  # a console in your browser, when you want to interrogate views.
  gem 'web-console'

  # silences logging of requests for assets
  gem 'quiet_assets'

  # enabling us to deploy via travis and encrypted keys!
  gem 'travis'
end

group :production do
  gem 'newrelic_rpm'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
gem 'unicorn'

# To use debugger
# gem 'debugger'

gem 'twitter-bootstrap-rails', '~> 2.2.0'

# use tire for ElasticSearch integration
gem 'tire'

# pagniate with will_paginate: https://github.com/mislav/will_paginate
gem 'will_paginate'
gem 'will_paginate-bootstrap', '~> 0.2.5' # Bootstrap 2 support breaks at v1.0

# include health_check, for system monitoring
gem 'health_check'

# use holder for placeholder images
gem 'holder_rails'

# use devise for auth/identity
gem 'devise','~>4.1.0'

# use gibbon for easy Mailchimp API access
gem 'gibbon', '~> 2.2.3'

# use twilio-ruby for twilio
gem 'twilio-ruby'

# use Wuparty for wufoo
gem 'wuparty'

# Use gsm_encoder to help text messages send correctly
gem 'gsm_encoder'

# use Delayed Job to queue messages
gem 'delayed_job_active_record'
gem 'daemons'

# for generating unique tokens for Person
gem 'has_secure_token'

# phone number validation
gem 'phony_rails'

# zip code validation
gem 'validates_zipcode'

# in place editing
gem 'best_in_place', '~> 3.0.1'

# validation for new persons on the public page.
gem 'jquery-validation-rails'


# for automatically populating tags
gem 'twitter-typeahead-rails'

# make ical events and feeds
gem 'icalendar'

# state machine for reservations.
gem 'aasm'

# cron jobs for backups and sending reminders
gem 'whenever', require: false

# natural language processing API
gem 'wit'

# handling emoji!
gem 'emoji', git: 'https://github.com/cromulus/emoji', branch: 'add_replace_unicode_moji_with_name'

# auditing.
gem 'paper_trail'
gem 'paper_trail-globalid'

gem 'fast_blank' # blank? rewritten in c
#gem 'faster_path' # soon! path, rewitted in rust. requires rust compiler

# storing money with money-rails
gem 'money-rails'

# masked inputs
gem 'maskedinput-rails'

group :test do
  # mock tests w/mocha
  gem 'mocha', require: false

  gem 'sqlite3', platform: [:ruby, :mswin, :mingw]

  # for JRuby
  gem 'jdbc-sqlite3', platform: :jruby
  gem 'memory_test_fix' # in memory DB, for the speedy

  # generate fake data w/faker: http://rubydoc.info/github/stympy/faker/master/frames
  gem 'faker'
  gem 'rubocop', require: false
  gem 'codeclimate-test-reporter', group: :test, require: nil
  gem 'coveralls', require: false
  # screenshots when capybara fails
  gem 'capybara-screenshot'

  # retry poltergeist specs. they are finicky
  gem 'rspec-retry'

  # calendaring tests will almost always break on saturdays.
  gem 'timecop'

  # webrick is slow, capybara will use puma instead
  gem 'puma'

  # in memory redis for testing only
  gem 'mock_redis'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'guard-minitest'
  gem 'guard-rubocop'
  gem 'guard-bundler', require: false
  gem 'capybara'
  gem 'capybara-email'
  gem 'pry'
  gem 'factory_girl_rails', require: false
  gem 'shoulda-matchers', '~> 3.1.1', require: false
  gem 'database_cleaner'
  gem 'poltergeist'
  gem 'sms-spec'
end
