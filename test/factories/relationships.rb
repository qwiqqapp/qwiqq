Factory.define :relationship do |f|
  f.user {|f| f.association(:user) }
  f.target {|f| f.association(:user) }
end
