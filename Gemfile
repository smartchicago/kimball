source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0.rc1'

gem 'sqlite3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.0.beta1'
  gem 'coffee-rails', '~> 4.0.0.beta1'

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
  gem 'capistrano', :git => "git://github.com/jimryan/capistrano.git", :branch => "support-json-manifest"
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

# use mysql in production
group :production do
  gem 'mysql2'
end

# include health_check, for system monitoring
gem "health_check"

# use holder for placeholder images
gem 'holder_rails'

# use devise for auth/identity
gem 'devise', branch: "rails4", git: "git://github.com/plataformatec/devise"

# use gibbon for easy Mailchimp API access
gem "gibbon"