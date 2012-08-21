# added rand to avoid duplicates
Factory.define :category do |f|
  f.name { %w(food ae beauty sports house travel fashion tech nolocation).shuffle.first + rand(100).to_s } 
end