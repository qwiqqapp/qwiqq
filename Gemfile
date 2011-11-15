source 'http://rubygems.org'

# hosting
gem "aws-s3"

# base
gem "rails", "3.0.7"
gem "rake", "0.8.7"
gem "rails3-generators"
gem "pg"
gem "bcrypt-ruby", :require => "bcrypt"

# views
gem "haml-rails"
gem "simple_form"
gem "htmlentities"

# images
gem "paperclip"
gem "rmagick", :require => false

# workers
gem "resque"
gem "resque-pool"

# services
gem "geokit"
gem "koala" # facebook
gem "twitter", "1.6.0"
gem "airbrake"
gem "daemons", :require => false
gem "httparty"

# search
gem "thinking-sphinx", "2.0.5"
gem "whenever"

gem 'postmark'
gem 'postmark-rails', '0.4.0'
gem 'activerecord-import'

gem "bcrypt-ruby", :require => "bcrypt"
gem "htmlentities"

# admin
gem "activeadmin", '0.3.1'

# memcached
gem "dalli"

# maxmind geo lookup
gem "geoip", "1.1.1"

# apple push notifications
gem 'apn_on_rails', :git => 'https://github.com/natescherer/apn_on_rails.git', :branch => 'rails3' 

# sms delivery with twilio
gem 'twilio-ruby'

gem 'kaminari'

group :test do
  gem "factory_girl_rails", '1.0.1'
  gem "ffaker"
  gem "mocha", :require => false
  gem 'fakeweb'
  gem 'resque_unit'
  gem 'database_cleaner'
  
  # autotest
  gem 'ZenTest'
  gem 'autotest-rails'
  gem 'autotest-fsevent'
end

group :development do
  gem "faker"
  gem "capistrano"
  gem "capistrano-ext"
end


group :production do
  gem "unicorn", :require => false
  gem "newrelic_rpm"
end

