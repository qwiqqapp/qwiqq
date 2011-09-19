Factory.define :share do |f|
  f.user {|f| f.association(:user) }
  f.deal {|f| f.association(:deal) }
end

Factory.define :facebook_share, :parent => :share do |f|
  f.service 'facebook'
end

Factory.define :twitter_share, :parent => :share do |f|
  f.service 'twitter'
end

Factory.define :email_share, :parent => :share do |f|
  f.service 'email'
  f.email   'adam@test.com'
end

Factory.define :sms_share, :parent => :share do |f|
  f.service 'sms'
  f.number  '(604) 618-5421'
end
