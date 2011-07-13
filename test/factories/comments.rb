Factory.define :comment do |f|
  f.user {|f| f.association(:user) }
  f.deal {|f| f.association(:deal) }
  f.body { Faker::Lorem.sentence(12) }
end
 