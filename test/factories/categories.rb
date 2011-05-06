Factory.define :category do |f|
  f.name { %w(food a&e beauty sports house travel fashion tech).shuffle.first } 
end