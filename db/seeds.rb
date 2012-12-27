# setup categories
puts '>> creating new categories'
Rake::Task['category:update'].invoke

puts '>> creating admin accounts'
AdminUser.create!(:email => 'john@qwiqq.me',              :password => 'maxim123', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'jack@qwiqq.me',              :password => 'qWiqq182', :password_confirmation => 'texasbbq')

AdminUser.create!(:email => 'brandon@novationmobile.com', :password => 'qWiqq182', :password_confirmation => 'texasbbq')

# 

