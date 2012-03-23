namespace :users do
  desc "Clear any #city fields set to an email address" 
  task :clear_city_fields_set_to_email_address => :environment do
    fixed = 0
    User.find_each do |user|
      if Qwiqq.email?(user.city)
        user.update_attribute(:city, "")
        fixed += 1
      end
    end
    p "Fixed #{fixed} users."
  end
  
  desc "Reset users counter cache"
  task :refresh_counter_cache => :environment do
    counters = [:followers, :following, :likes, :comments, :deals]
    User.find_each do |user|
      p "refresh counter cache for user #{user.id}"
      counters.each do |c|
        User.reset_counters(user.id, c)
      end
    end
  end
end
