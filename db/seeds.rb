Factory.find_definitions


categories  = []
locations   = []
commenters  = []

# setup categories
%w(food a&e beauty sports house travel fashion tech).each do |c|
  categories << Factory(:category, :name => c)
end

# setup locations
500.times.each do 
  locations << Factory(:location) 
end

10.times.each do
  commenters << Factory(:user)
end


30.times.each do 
  user = Factory(:user)
  
  20.times.each do
    location  = locations.shuffle.first
    category  = categories.shuffle.first
    
    deal = Factory(:deal, :user => user, :location => location, :category => category)
    
    5.times.each do
      Factory(:comment, :deal => deal, :user => commenters.shuffle.first)
    end
  end
end
