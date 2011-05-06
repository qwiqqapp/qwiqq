Factory.define :deal do |f|
  f.name      { Faker::Product.product_name }
  f.price     { Random.new.rand(89..9000) }
  f.percent   0 #{ Random.new.rand(0..99) }
end
