class ReportsController < ApplicationController
  def report
   deals = Deal.premium.recent.sorted.popular.first(3)
   user = User.find_by_email("mscaria@novationmobile.com")
   increment = 0
     deals.each do |deal|
       if deal.shares_count.is_a?(Integer)
         increment = increment + deal.shares_count
         Mailer.category_test(user, increment).deliver
       end
     end

    @average_shares_per_post 
  end
end
