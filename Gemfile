source "http://rubygems.org"

# hosting
gem 'aws-sdk',"1.8.1.2"

# performance
gem 'newrelic_rpm'

#env variables
gem 'figaro'

# base
gem "rails", "3.2.12"
gem "railties"
gem "actionpack"
gem "rake"
gem "pg", "0.11.0"
gem "bcrypt-ruby"
gem "activerecord-import","0.3.0"
gem "coffee-rails"
gem 'coffee-script-source', '~> 1.4.0' # ADD THIS LINE, 1.5.0 doesn't compile ActiveAdmin JavaScript files
gem "oauth"

# views
gem "haml-rails", "~> 0.3.5" #DO NOT UPGRADE, PREPARE FOR THIS TO BREAK HARD
gem "htmlentities"

# images
gem "paperclip"
gem "rmagick", :require => false

# workers
gem "resque"
gem "rufus-scheduler", "~> 2.0.17"
gem "whenever", "~> 0.8.2"

# services
gem "geokit"
gem "koala", "1.5.0" # facebook
gem "twitter", "~> 4.6.2"
gem "airbrake"
gem "daemons", :require => false
gem "skittles", :git => "https://github.com/anthonator/skittles.git"
gem "httparty"
gem "rails_autolink"
gem "socialyzer"

# PayPal
gem "paypal", "~> 2.0.0"
gem "active_paypal_adaptive_payment"

# search
gem "riddle", "~> 1.5.4"
gem "thinking-sphinx", "2.0.10"
gem "flying-sphinx", "0.8.0"
gem "kaminari"

# mail
gem "postmark"
gem "postmark-rails", "0.4.0"

# admin
gem "activeadmin", "0.5.1"
gem "jquery-rails"
gem "sass-rails", "~> 3.2.5"
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
