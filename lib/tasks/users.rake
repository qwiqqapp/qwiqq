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
  
  desc "Update every users deal_count"
  task :update_deal_count => :environment do
    #User.find_each do |user|
    #  user.deals_count = Deal.where('user_id=? AND hidden=FALSE',user.id).count
    #  user.save
    #end
    user = User.find_by_email("michaelscaria26@gmail.com")
    puts "Initial deal count:#{user.deals_count}"
    user.deals_count = Deal.where('user_id=? AND hidden=FALSE',user.id).count
    user.save
    puts "Final deal count:#{user.deals_count}"
  end
end
