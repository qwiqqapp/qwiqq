source "http://rubygems.org"

# hosting
gem 'aws-sdk'

# performance
gem 'newrelic_rpm'

# base
gem "rails", "3.2.11"
gem "railties"
gem "actionpack"
gem "rake"
gem "pg", "0.11.0"
gem "bcrypt-ruby"
gem "activerecord-import"
gem "coffee-rails"

# views
gem "haml-rails"
gem "htmlentities"

# images
gem "paperclip"
gem "rmagick", :require => false

# workers
gem "resque"
gem "rufus-scheduler", "~> 2.0.17"

# services
gem "geokit"
gem "koala", "1.5.0" # facebook
gem "twitter", "~> 2.5.0"
gem "airbrake"
gem "daemons", :require => false
gem "skittles", "0.6.0" # foursquare, update to 0.6?
gem "httparty"
gem "rails_autolink"
gem "socialyzer"

# PayPal
gem "paypal", "~> 2.0.0"
gem "adaptive_pay"

# search
gem "riddle", "~> 1.5.4"
gem "thinking-sphinx", "2.0.10"
gem "flying-sphinx", "0.8.0"
gem "kaminari"

# mail
gem "postmark"
gem "postmark-rails", "0.4.0"

# admin
gem "activeadmin"
gem "jquery-rails"
gem "sass-rails"
gem "meta_search",    '>= 1.1.0.pre'

# memcached
gem "dalli"

# apple push notifications
gem "urbanairship"

# sms delivery with twilio
gem "twilio-ruby"

group :test do
  gem "factory_girl_rails", "1.0.1"
  gem "ffaker"
  gem "mocha", :require => false
  gem "fakeweb"
  gem "resque_unit"
  gem "database_cleaner"
  
  # autotestb
  gem 'guard-test'
end

group :development do
  gem "heroku"
  gem "taps"
  gem "faker"
  gem "sqlite3"
end

group :assets do
  gem "uglifier"
end

group :production do
  gem "thin"
end
