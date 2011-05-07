Factory.find_definitions

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
40.times.each do
  user  = Factory(:user, :photo => user_image)
  
  8.times.each do
    location  = locations.shuffle.first
    category  = categories.shuffle.first
    
    deal = Factory(:deal, :user => user, :location => location, :category => category, :photo => product_image)
    
    3.times.each do
      Factory(:comment, :deal => deal, :user => commenters.shuffle.first)
    end
    
    # 5.times.each do
    #   Factory(:comment, :deal => deal, :body => nil, :user => commenters.shuffle.first)
    # end
  end
end
