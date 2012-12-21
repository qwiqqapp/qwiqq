namespace :mail do

  # called everyday but checks if specific day to make it weekly updates
  desc "Send out a weekly update of what's up in Qwiqq"
  task :weekly_update => :environment do
    #make sure it is a Monday that the email is sent out
    if Date.today.wday != 1
      next
    else
   users = User.all
     deals = Deal.premium.recent.sorted.popular.first(3)
     if users
       users.each do |u|
         if u
           if u.send_notifications
             Mailer.weekly_update(u, deals).deliver
           end
         end
       end
     end
    end
  end
  
    # called everyday but checks if specific day to make it weekly updates
  desc "Send out a weekly update of what's up in Qwiqq"
  task :weekly_update_for_jack => :environment do
    #make sure it is a Monday that the email is sent out
    if Date.today.wday != 1
      next
    else
      user = User.find_by_email("jack@qwiqq.me")
      if user.send_notifications 
        deals = Deal.premium.recent.sorted.popular.first(3)
        Mailer.weekly_update(user, deals).deliver
      end
    end
  end
  
    # called everyday but checks if specific day to make it weekly updates
  desc "Let Qwiqq users know that there is a free 60 day Constant Contact trial available for them"
  task :constant_contact_email => :environment do
    #make sure it is a day that is selected
    if Date.today.wday != 4
      next
    else
     users = User.all
     users.each do |u|
       if u
         if u.send_notifications
           Mailer.constant_contact_trial(u).deliver
         end
       end
     end
    end
  end
  
  task :send_michael => :environment do
    user = User.find_by_email("michaelscaria26@gmail.com")
    deal = Deal.find(9960)
    Mailer.category_test(user, deal).deliver
  end
end

