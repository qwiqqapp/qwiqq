source 'http://rubygems.org'

# hosting
gem "aws-s3"

# base
gem "rails", "3.0.7"
gem "rake", "0.8.7"
gem "rails3-generators"
gem "mysql2", "~> 0.2.7"   #postgresql to match staging and production
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
gem "indextank"
gem "hoptoad_notifier"

gem 'postmark'
gem 'postmark-rails', '0.4.0'
gem 'activerecord-import'

gem "activeadmin"
gem "bcrypt-ruby", :require => "bcrypt"
gem "htmlentities"

# admin
gem "activeadmin"

# memcached
gem "dalli"

group :test do
  gem "factory_girl_rails", '1.0.1'
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
  gem "capistrano"
  gem "capistrano-ext"
  gem "wirble"
end


group :production do
  gem "unicorn", :require => false
  gem 'rpm_contrib'  
  gem "newrelic_rpm"
end
