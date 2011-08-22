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
