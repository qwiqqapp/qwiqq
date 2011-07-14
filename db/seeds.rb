puts '+ creating admin accounts'
AdminUser.create!(:email => 'adam@gastownlabs.com',     :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'brian@gastownlabs.com',    :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'melanie@gastownlabs.com',  :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'john@qwiqq.me',            :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'jack@qwiqq.me',            :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'eoin@gastownlabs.com',     :password => 'texasbbq', :password_confirmation => 'texasbbq')

# setup categories
puts '+ creating categories'
%w(food ae beauty sport house travel fashion tech used family).each do |c|
  puts ' + creating category ' + c
  categories << Factory(:category, :name => c)
end

