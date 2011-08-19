Factory.define :deal do |f|
  f.user {|f| f.association(:user) }
  f.name { Faker::Product.product_name }
  f.price { rand(200) }
  f.likes_count { rand(300) }
  f.comments_count { rand(30) }
  f.percent   0 #{ Random.new.rand(0..99) }
  
  f.lat { Faker::Geolocation.lat }
  f.lon { Faker::Geolocation.lng }
  f.location_name { "#{Faker::Address.street_address}, #{Faker::Address.city}" }
  
  f.category {|f| f.association(:category)}
end
