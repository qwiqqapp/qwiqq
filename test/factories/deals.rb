Factory.define :deal do |f|
  f.name      { Faker::Product.product_name }
  f.price     { rand(200) }
  f.percent   0 #{ Random.new.rand(0..99) }
  
  f.lat       { Faker::Geolocation.lat }
  f.long      { Faker::Geolocation.lng }
end
