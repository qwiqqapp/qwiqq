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
     deals = Deal.where('created_at > ?', Deal::MAX_AGE.days.ago)
     if deals.empty?
       puts "No deals older than #{Deal::MAX_AGE} days"
     else
       puts "Removing #{deals.size} deals, which are older than #{Deal::MAX_AGE} days"
       deals.destroy_all
     end
     puts "success!"
  end
  
end

