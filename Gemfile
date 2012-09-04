source "http://rubygems.org"

# hosting
gem 'aws-sdk', '~> 1.3.4'

# performance
gem 'newrelic_rpm'

#gem "sass-rails", "3.2.0"

# base
gem "rails", "3.2.8"
gem "rake", "0.8.7"
gem "pg", "0.11.0"
gem "bcrypt-ruby", :require => "bcrypt"
gem "activerecord-import"

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
gem "twitter", "~> 2.0.0"
gem "airbrake"
gem "daemons", :require => false
gem "skittles", "0.6.0" # foursquare, update to 0.6?
gem "httparty"
gem "rails_autolink"

# search
gem "riddle", "1.5.0"
gem "thinking-sphinx", "2.0.10"
gem "flying-sphinx", "0.7.0"  #need to upgrade to 0.6.4, recommended on flysphinx docs
gem "kaminari"

# mail
gem "postmark"
gem "postmark-rails", "0.4.0"

# admin
gem "activeadmin"

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
end

group :assets do
  gem "uglifier"
  gem "coffee-rails"
end

group :production do
  gem "thin"
end