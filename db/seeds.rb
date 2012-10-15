# setup categories
puts '>> creating new categories'
Rake::Task['category:update'].invoke

puts '>> creating admin accounts'
AdminUser.create!(:email => 'adam@gastownlabs.com',       :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'brian@gastownlabs.com',      :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'eoin@gastownlabs.com',       :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'kristina@gastownlabs.com',   :password => 'texasbbq', :password_confirmation => 'texasbbq')

AdminUser.create!(:email => 'john@qwiqq.me',              :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'jack@qwiqq.me',              :password => 'texasbbq', :password_confirmation => 'texasbbq')

AdminUser.create!(:email => 'brandon@novationmobile.com', :password => 'texasbbq', :password_confirmation => 'texasbbq')

# 

