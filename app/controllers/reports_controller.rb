class ReportsController < ApplicationController
  def report
   deals = Deal.all
   user = User.find_by_email("mscaria@novationmobile.com")
   increment = 0
     deals.each do |deal|
       if deal.shares_count.is_a?(Integer)
         increment = increment + deal.shares_count
       end
     end
   Mailer.category_test(user, increment).deliver
   Mailer.category_test(user, deals.count).deliver

   @average_shares_per_post = increment / deals.count
  end
end