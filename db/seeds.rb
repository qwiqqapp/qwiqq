Factory.find_definitions

categories  = []
users       = []

def user_image
  File.new("test/fixtures/users/#{rand(5)}.jpg")
end

def product_image
  File.new("test/fixtures/products/#{rand(22)}.jpg")
end

puts '+ creating admin accounts'
# gtl and qwiqq admins
AdminUser.create!(:email => 'adam@gastownlabs.com',     :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'brian@gastownlabs.com',    :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'melanie@gastownlabs.com',  :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'john@qwiqq.me',            :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'jack@qwiqq.me',            :password => 'texasbbq', :password_confirmation => 'texasbbq')

# gtl and qwiqq users
users << User.create(:email => 'adam@test.com',     :password => 'tester', :password_confirmation => 'tester')
users << User.create(:email => 'brian@test.com',    :password => 'tester', :password_confirmation => 'tester')
users << User.create(:email => 'melanie@test.com',  :password => 'tester', :password_confirmation => 'tester')
users << User.create(:email => 'john@test.com',     :password => 'tester', :password_confirmation => 'tester')
users << User.create(:email => 'jack@test.com',     :password => 'tester', :password_confirmation => 'tester')

# setup categories
%w(food ae beauty sport house travel fashion tech).each do |c|
  puts '+ creating category'
  categories << Factory(:category, :name => c)
end

# create users
30.times.each do
  puts '+ creating user'  
  users << Factory(:user, :photo => user_image)
end

# create deals and comments for users
users.each do |user|
  other_users = users - [user]
  
  rand(10).times.each do
    puts ' + creating deal for user'
    category  = categories.shuffle.first
    
    deal = Factory(:deal, :user => user, :category => category, :photo => product_image)
    
    rand(5).times.each do
      puts '  + creating comment for user'
      Factory(:comment, :deal => deal, :user => other_users.shuffle.first)
    end
    
    rand(10).times.each do
      puts ' + creating like for user'
      Like.create(:user => other_users.shuffle.first, :deal => deal)
    end
  end
end




