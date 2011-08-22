Factory.define :like do |f|
  f.user {|f| f.association(:user) }
  f.deal {|f| f.association(:deal) }
end