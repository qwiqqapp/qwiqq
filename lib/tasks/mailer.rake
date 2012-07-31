namespace mailer do

  # called everyday but checks if specific day to make it weekly updates
  desc "Send out a weekly update of what's up in Qwiqq"
  task :weekly_update => :environment do
    #make sure it is a Monday that the email is sent out
    return if Date.today.wday != 2
    user = User.find_by_email("michaelscaria26@gmail.com")
    Mailer.weekly_update(user).deliver
      
  end
end

