Factory.define :comment do |f|
  f.body { Faker::Lorem.sentence(12) }
end
  