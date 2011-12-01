Factory.define :category do |f|
  f.name { %w(food ae beauty sports house travel fashion tech).shuffle.first } 
end