class ReportsController < ApplicationController
  def report
    deals = Deal.all
    increment_share_average = 0
    increment_people_average = 0 
    deals.each do |deal|
      if deal.shares_count.is_a?(Integer)
        increment_share_average = increment_share_average + deal.shares_count
      end 
      user_ids = []
      deal.events.each do |event|
        if event.event_type == "share"
          user_ids.push(event.created_by_id.hash)
        end
      end
      user_ids = user_ids.uniq
      increment_people_average = increment_people_average + user_ids.count
    end

    @average_shares_per_post = increment_share_average / deals.count.to_f    
    @average_people_share_per_post = increment_people_average / deals.count.to_f   
  end
end
