Factory.find_definitions

categories  = []
deals       = []
users       = []

def user_image(name=rand(5))
  File.new("test/fixtures/users/#{name}.jpg")
end

def product_image(name=rand(22))
  File.new("test/fixtures/products/#{name}.jpg")
end

puts '+ creating admin accounts'
AdminUser.create!(:email => 'adam@gastownlabs.com',     :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'brian@gastownlabs.com',    :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'melanie@gastownlabs.com',  :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'john@qwiqq.me',            :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'jack@qwiqq.me',            :password => 'texasbbq', :password_confirmation => 'texasbbq')

# create users
puts '+ creating user accounts'
30.times.each do
  puts '+ creating user'  
  users << Factory(:user, :photo => user_image)
end

users << User.create(:country => 'ca', :city => 'vancouver',  :photo => user_image,    :name => 'adam',     :email => 'adam@test.com',     :password => 'tester', :password_confirmation => 'tester')
users << User.create(:country => 'ca', :city => 'vancouver',  :photo => user_image,    :name => 'brian',    :email => 'brian@test.com',    :password => 'tester', :password_confirmation => 'tester')
users << User.create(:country => 'ca', :city => 'vancouver',  :photo => user_image,    :name => 'melanie',  :email => 'melanie@test.com',  :password => 'tester', :password_confirmation => 'tester')
users << User.create(:country => 'us', :city => 'texas',      :photo => user_image(4), :name => 'john',     :email => 'john@test.com',     :password => 'tester', :password_confirmation => 'tester')
users << User.create(:country => 'us', :city => 'texas',      :photo => user_image,    :name => 'jack',     :email => 'jack@test.com',     :password => 'tester', :password_confirmation => 'tester')

# setup categories
%w(food ae beauty sport house travel fashion tech).each do |c|
  puts '+ creating category'
  categories << Factory(:category, :name => c)
end


# create deals and comments for users
users.each do |user|
  other_users = users - [user]
  
  rand(10).times.each do
    puts ' + creating deal for user'
    deals << deal = Factory(:deal, :user => user, :category => categories.shuffle.first, :photo => product_image)
    
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


# set 5 deals to premium
5.times.each do
  puts ' set deal to premium'
  deals.shuffle.first.update_attribute(:premium, true)
end




