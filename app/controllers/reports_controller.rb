class ReportsController < ApplicationController
  def report
   deals = Deal.all
   increment_share_average = 0
   increment_people_average = 0 
   deals.each do |deal|
     if deal.shares_count.is_a?(Integer)
       increment_share_average = increment_share_average + deal.shares_count
     end  
   end
   Mailer.category_test(user, increment).deliver
   Mailer.category_test(user, deals.count).deliver

   @average_shares_per_post = increment / deals.count
  end
end
