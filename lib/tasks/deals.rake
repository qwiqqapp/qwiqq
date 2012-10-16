namespace :deals do
  desc "Refresh deal counter cache"
  task :refresh_cache => :environment do
    counters = [:comments, :likes, :shares]
    Deal.find_each do |deal|
      puts "refresh counter cache for deal #{deal.id}"
      counters.each do |c|
        Deal.reset_counters(deal.id, c)
      end
    end
    
    puts "success!"
  end
  
  # TODO replace with deleted_at and default_scope later
  # max age set in deal model
  desc "Remove deals older than age"
  task :remove_old => :environment do
     deals = Deal.where('created_at < ?', Deal::MAX_AGE.days.ago)
     if deals.empty?
       puts "No deals older than #{Deal::MAX_AGE} days"
     else
       puts "Removing #{deals.size} deals, which are older than #{Deal::MAX_AGE} days"
       deals.destroy_all
     end
     puts "success!"
  end
  
  # reset the number_of_users_shared for every deal
  desc "Set the number of users shared"
  task :number_of_users_shared => :environment do
    user = User.find_by_email("mscaria@novationmobile.com")
    Mailer.share_post(user).deliver

    deals = Deal.all
    if deals.empty?
    else
    deals.each do |deal|
      puts "Resetting the number_of_users_shared"
      #set to zero as default
      average = 0
      if deal.shares_count == 1
        average = 1 #=> only one share so one user
      end
      if deal.shares_count > 1 #=> more than one share so run algorithm
        user_ids = []
        if deal.events
          user_ids << deal.events.map do |event|
            if event.event_type == "share"
              event.created_by_id.hash
            end
          end
          user_ids = user_ids[0].uniq
          user_ids = user_ids.compact
          average = user_ids.count
        end
     end
     deal.number_users_shared = average
     deal.save
    end
   end
     puts "Success!"
     Mailer.create_post(user).deliver
  end
end

