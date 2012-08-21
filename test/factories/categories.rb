# added rand to avoid duplicates
Factory.define :category do |f|
  f.name { %w(ae food beauty sports house travel fashion tech).shuffle.first + rand(100).to_s } 
end