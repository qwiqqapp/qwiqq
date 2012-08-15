namespace :mail do

  # called everyday but checks if specific day to make it weekly updates
  desc "Send out a weekly update of what's up in Qwiqq"
  task :weekly_update => :environment do
    #make sure it is a Monday that the email is sent out
    if Date.today.wday != 2
      next
    else
     users = [User.find_by_email("copley.brandon@gmail.com"), User.find_by_email("michaelscaria@yahoo.com"), User.find_by_email("michael@getliquid.com"), gUser.find_by_email("michaelscaria26@gmail.com")]
     deals = Deal.premium.recent.sorted.popular.first(3)
     if users
       users.each do |u|
         Mailer.weekly_update(u, deals).deliver
       end
     end
    end
  end
    # called everyday but checks if specific day to make it weekly updates
  desc "Send out a weekly update of what's up in Qwiqq"
  task :weekly_update_for_jack => :environment do
    #make sure it is a Monday that the email is sent out
    if Date.today.wday != 2
      next
    else
      user = User.find_by_email("jack@qwiqq.me")
      deals = Deal.premium.recent.sorted.popular.first(3)
      Mailer.weekly_update(user, deals).deliver
    end
  end
end

