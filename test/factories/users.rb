Factory.define :user do |f|
  f.first_name            { Faker::Name.first_name}
  f.last_name             { Faker::Name.last_name}
  f.username              { Faker::Name.name.gsub(/\W/, '') }
  f.email                 { Faker::Internet.email}
  f.city                  { Faker::Address.city}
  f.country               { Faker::Address.us_state}
  f.phone                 { Faker::PhoneNumber.phone_number }
  f.website               { Faker::Internet.domain_name }
  f.password              'tester'
  f.password_confirmation 'tester'
end
