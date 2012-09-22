class ReportsController < ApplicationController
  def report
   deals = Deal.premium.recent.sorted.popular.first(3)
   user = User.find_by_email("jack@qwiqq.me")
     deals.each do |deal|
       if deal.shares_count.is_a?(Integer)
         Mailer.share_post(user).deliver
       else
         Mailer.create_post(user).deliver
       end
     end

    @average_shares_per_post 
  end
end
