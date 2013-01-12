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

    deals = Deal.all
    if deals.empty?
    else
    deals.each do |deal|
      cloned_deal = deal.clone
      #Resetting the number_of_users_shared
      #set to zero as default
      average = 0
      if cloned_deal.shares_count == 1
        average = 1 #=> only one share so one user
      end
      if cloned_deal.shares_count > 1 #=> more than one share so run algorithm
        user_ids = []
        if cloned_deal.events
          user_ids << cloned_deal.events.map do |event|
            if event.event_type == "share"
              event.created_by_id.hash
            end
          end
          user_ids = user_ids[0].uniq
          user_ids = user_ids.compact
          average = user_ids.count
        end
     end
     cloned_deal.number_users_shared = average
     cloned_deal.save
    end
   end
  end
  
    desc "Remove deals older than age"
  task :update_4SQ_deals => :environment do
     deals = Deal.where("foursquare_venue_id IS NOT NULL AND located = false")
     puts "4SQ COUNT:#{deals.count}"
     deals.order("created_at desc").limit(10) do |d|
       if d.foursquare_venue_id? && d.foursquare_venue_name.nil?
         d.locate! rescue nil
         puts "Deal now has 4SQ Location:#{d.foursquare_venue_name}"
       end
     end
     puts "success!"
  end
end

