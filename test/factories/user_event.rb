Factory.define :user_event do |f|
  f.event_type { %w(like comment share follower mention).shuffle.first }
end