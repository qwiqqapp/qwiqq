source 'http://rubygems.org'

# hosting
gem "heroku"
gem "aws-s3"

# base
gem "rails", "3.0.7"
gem "rake", "0.8.7"
gem "json"
gem "rails3-generators"
gem "mysql2", "~> 0.2.7"   #postgresql to match staging and production
gem "bcrypt-ruby", :require => "bcrypt"

# views
gem "haml-rails"
gem "simple_form"
gem 'htmlentities'

# images
gem "paperclip"
gem "rmagick", :require => false

# workers
gem "resque"

# services
gem "geokit"
gem "koala" # facebook
gem "twitter", "1.6.0"
gem "indextank"
gem 'hoptoad_notifier'

# admin
gem "activeadmin"

group :test do
  gem "factory_girl_rails"
  gem "ffaker"
  gem "mocha", :require => false
  gem 'fakeweb'
  gem 'resque_unit'
  
  # autotest
  gem 'ZenTest'
  gem 'autotest-rails'
  gem 'autotest-fsevent'
end

group :development do
  gem "wirble"
end

