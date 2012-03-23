namespace :deals do
  desc "Clean deal location fields"
  task :clean_location_name => :environment do
    fixed = 0
    Deal.find_each do |deal|
      next unless location_name = deal.location_name
      if location_name[0] == "-"
        deal.update_attribute(:location_name, location_name.slice(1..-1))
        fixed += 1
      end
    end
    p "Fixed #{fixed} deals."
  end
  
  desc "Refresh deal counter cache"
  task :refresh_counter_cache => :environment do
    counters = [:comments, :likes, :shares]
    Deal.find_each do |deal|
      p "refresh counter cache for deal #{deal.id}"
      counters.each do |c|
        Deal.reset_counters(deal.id, c)
      end
    end
  end
end

