Factory.define :deal do |f|
  f.name { Faker::Product.product_name }
  f.price { rand(200) }
  f.percent   0 #{ Random.new.rand(0..99) }
  f.lat { Faker::Geolocation.lat }
  f.lon { Faker::Geolocation.lng }
  f.location_name { "#{Faker::Address.street_address}, #{Faker::Address.city}" }
  
  f.user {|f| f.association(:user) }
  f.category {|f| f.association(:category)}
end


# gastown
Factory.define :deal_at_gastownlabs, :parent => :deal do |f|
  f.lat             49.283846
  f.lon             -123.109905
  f.location_name   "207 West Hastings, Vancouver"
end

#gastown
Factory.define :deal_at_sixacres, :parent => :deal do |f|
  f.lat             49.283323
  f.lon             -123.104532
  f.location_name   "203 Carrall Street, Vancouver"
end

# kits
Factory.define :deal_at_thelocal, :parent => :deal do |f|
  f.lat             49.272481
  f.lon             -123.15551
  f.location_name   "2210 Cornwall Avenue, Vancouver"
end

Factory.define :deal_at_seattle, :parent => :deal do |f|
  f.lat             47.619905
  f.lon             -122.349072
  f.location_name   "203 6th Avenue, Seattle"
end
