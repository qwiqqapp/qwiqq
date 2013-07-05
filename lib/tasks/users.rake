namespace :users do
  desc "Clear any #city fields set to an email address" 
  task :clear_city_fields_set_to_email_address => :environment do
    fixed = 0
    User.find_each do |user|
      if Qwiqq.email?(user.city)
        puts "updating user, clear city fields?: #{@user.id}"
        user.update_attribute(:city, "")
        fixed += 1
      end
    end
    p "Fixed #{fixed} users."
  end
  
  desc "Reset users counter cache"
  task :refresh_counter_cache => :environment do
    counters = [:likes, :comments, :deals]
    User.find_each do |user|

      puts " - refreshing counter cache for user #{user.id}"
      user.update_relationship_cache
      
      counters.each do |c|
        User.reset_counters(user.id, c)
      end
    end
  end
  
    desc "Set all number of users shared to true"
  task :set_to_true => :environment do
    User.find_each do |user|
      user.sent_facebook_push = true
      user.save
    end
  end
  
  desc "Update every users deal_count FOR MICHAEL"
  task :log_devices, [:user] => :environment do |t, args| 
    user = User.find(args[:user])
    puts "Devices:#{user.push_devices}"
  end
  
  desc "Update every users deal_count"
  task :update_deal_count => :environment do
    User.find_each do |user|
      user.deals_num = Deal.where('user_id=? AND hidden=FALSE',user.id).count
      user.save
    end
  end

  desc "Update users location"
  task :update_location => :environment do
    users = User.where("city IS NOT NULL AND country IS NOT NULL AND lon IS NULL AND lat IS NULL")
    puts users.count
    users.each do |user|
      s = Geocoder.search("#{user.city}, #{user.country}")
      puts "user:#{user.id} lat:#{s[0].latitude} lon:#{s[0].longitude}"
      user.lat = s[0].latitude
      user.lon = s[0].longitude
      user.save
    end
  end


end
