namespace :mail do

  # called everyday but checks if specific day to make it weekly updates
  desc "Send out a weekly update of what's up in Qwiqq"
  task :weekly_update => :environment do
    #make sure it is a Monday that the email is sent out
    if Date.today.wday != 3
      next
    else
      user = User.find_by_email("michaelscaria26@gmail.com")
      Mailer.create_post(user).deliver
      deal = Deal.premium.recent.sorted.popular.first(1)
      Mailer.weekly_update(user, deal).deliver
    end
  end
end

