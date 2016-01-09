source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.0'

#gem 'pg' # soooooon!
gem 'mysql2', '~> 0.3.18'

gem 'dotenv-rails'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', platforms: :ruby

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

# Deploy with Capistrano
group :development do

  # gem 'capistrano'
  # mainline cap is busted w/r/t Rails 4. Try this fork instead.
  # src: https://github.com/capistrano/capistrano/pull/412
  gem 'capistrano', :git => "git://github.com/capistrano/capistrano.git", :tag => "v2.15.4"
  gem 'rack-mini-profiler'
  gem 'bullet'
  gem 'ruby-prof'
  gem 'annotate'
end

# To use debugger
# gem 'debugger'

gem 'newrelic_rpm'
gem 'twitter-bootstrap-rails'

# use tire for ElasticSearch integration
gem "tire"

# pagniate with will_paginate: https://github.com/mislav/will_paginate
gem 'will_paginate'
gem 'will_paginate-bootstrap' # https://github.com/nickpad/will_paginate-bootstrap

<<<<<<< e7d9058a6244f66d6bc80a4c40ab8ffd8f2ddafe
# use mysql in production
group :production do
  gem 'mysql2'

end

gem "health_check" # include health_check, for system monitoring
=======
# include health_check, for system monitoring
gem "health_check"
>>>>>>> upgraded to 4.1, all tests pass

# use holder for placeholder images
gem 'holder_rails'

# use devise for auth/identity
gem 'devise', '~> 3.0'

# use gibbon for easy Mailchimp API access
gem "gibbon"

# use twilio-ruby for twilio
gem "twilio-ruby"

# use Wuparty for wufoo
gem "wuparty"


# Use gsm_encoder to help text messages send correctly
gem "gsm_encoder"

# use Delayed Job to queue messages
gem 'delayed_job_active_record'
gem 'daemons'

# mock tests w/mocha
gem "mocha", :require => false

group :testing do
  # mock tests w/mocha
  gem "mocha", :require => false

  gem "sqlite3"
  gem 'memory_test_fix' # in memory DB, for the speedy

  # generate fake data w/faker: http://rubydoc.info/github/stympy/faker/master/frames
  gem "faker"
end
