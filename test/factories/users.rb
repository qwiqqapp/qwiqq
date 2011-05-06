Factory.define :user do |f|
  f.name      { Faker::Name.name}
  f.email     { Faker::Internet.email}
  f.city      { Faker::Address.city}
  f.country   { Faker::Address.us_state}
end