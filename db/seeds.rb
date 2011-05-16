Factory.find_definitions

puts '+ creating admin accounts'
# gtl admins
AdminUser.create!(:email => 'adam@gastownlabs.com', :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'brian@gastownlabs.com', :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'melanie@gastownlabs.com', :password => 'texasbbq', :password_confirmation => 'texasbbq')

# qwiqq admins
AdminUser.create!(:email => 'john@qwiqq.me', :password => 'texasbbq', :password_confirmation => 'texasbbq')
AdminUser.create!(:email => 'jack@qwiqq.me', :password => 'texasbbq', :password_confirmation => 'texasbbq')



categories  = []
locations   = []
commenters  = []

def user_image
  File.new("test/fixtures/users/#{rand(5)}.jpg")
end

def product_image
  File.new("test/fixtures/products/#{rand(22)}.jpg")
end


# setup categories
%w(food a&e beauty sports house travel fashion tech).each do |c|
  categories << Factory(:category, :name => c)
end

# setup locations
100.times.each do 
  locations << Factory(:location) 
end

# setup commenters
10.times.each do
  commenters << Factory(:user, :photo => user_image)
end

# create users, deals and comments
20.times.each do
  puts '+ creating user'
  user  = Factory(:user, :photo => user_image)
  
  5.times.each do
    puts ' + creating deal'
    location  = locations.shuffle.first
    category  = categories.shuffle.first
    
    deal = Factory(:deal, :user => user, :location => location, :category => category, :photo => product_image)
    
    3.times.each do
      puts '  + creating comment'
      Factory(:comment, :deal => deal, :user => commenters.shuffle.first)
    end
    
    # 5.times.each do
    #   Factory(:comment, :deal => deal, :body => nil, :user => commenters.shuffle.first)
    # end
  end
end




