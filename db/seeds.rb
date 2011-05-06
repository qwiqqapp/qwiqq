Factory.find_definitions

categories  = []
locations   = []
commenters  = []

def user_image
  File.new("test/fixtures/users/#{Random.new.rand(0..4)}.jpg")
end

def product_image
  File.new("test/fixtures/products/#{Random.new.rand(0..21)}.jpg")
end


# setup categories
%w(food a&e beauty sports house travel fashion tech).each do |c|
  categories << Factory(:category, :name => c)
end

# setup locations
500.times.each do 
  locations << Factory(:location) 
end

# setup commenters
10.times.each do
  commenters << Factory(:user, :photo => user_image)
end

# create users, deals and comments
5.times.each_with_index do |i|
  user  = Factory(:user, :photo => user_image)
  
  20.times.each_with_index do |i|
    location  = locations.shuffle.first
    category  = categories.shuffle.first
    
    deal = Factory(:deal, :user => user, :location => location, :category => category, :photo => product_image)
    
    5.times.each do
      Factory(:comment, :deal => deal, :user => commenters.shuffle.first)
    end
  end
end
