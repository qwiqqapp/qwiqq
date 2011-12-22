source "http://rubygems.org"

# hosting
gem "aws-s3"

# base
gem "rails", "3.1.3"
gem "rake", "0.8.7"
gem "pg", "0.11.0"
gem "bcrypt-ruby", :require => "bcrypt"
gem "activerecord-import"

# views
gem "haml-rails"
gem "sass-rails"
gem "htmlentities"

# images
gem "paperclip"
gem "rmagick", :require => false

# workers
gem "resque"

# services
gem "geokit"
gem "koala" # facebook
gem "twitter", "1.6.0"
gem "airbrake"
gem "daemons", :require => false
gem "skittles" # foursquare

# search
gem "riddle", "1.4.0"
gem "thinking-sphinx", "2.0.5"
gem "flying-sphinx", "0.6.0"
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
  
  # autotest
  gem "ZenTest"
  gem "autotest-rails"
  gem "autotest-fsevent"
end

group :development do
  gem "heroku"
  gem "taps"
  gem "faker"
end

group :assets do
  gem "uglifier"
end

group :production do
  gem "thin"
end
