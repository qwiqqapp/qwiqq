class ReportsController < ApplicationController
  def report
   user = User.find_by_email("mscaria@novationmobile.com")
   userm = User.find_by_email("michaelscaria26@gmail.com")
   deals = userm.deals.sorted.limit(4)
   increment_share_average = 0
   increment_people_average = 0
     deals.each do |deal|
       if deal.shares_count.is_a?(Integer)
         increment_share_average = increment_share_average + deal.shares_count
       end
       
     user_ids = []
       deal.events.each do |event|
         if event.event_type == "share"
           user_ids.push(event.created_by_id)
         end
       end
     Mailer.category_test(user, user_ids).deliver

     end
   #Mailer.category_test(user, increment_share_average).deliver
   #Mailer.category_test(user, deals.count).deliver

   @average_shares_per_post = increment_share_average / deals.count.to_f    
    
  end
end
