Factory.define :location do |f|
  f.name      { Faker::Company.name }
  f.lat       { Faker::Geolocation.lat }
  f.lon       { Faker::Geolocation.lng }
  f.address   { Faker::Address.street_address }
  f.city      { Faker::Address.city }
  f.country   "US"
  f.state     { Faker::Address.us_state }
  f.postcode  { Faker::Address.zip_code }
end                                            
