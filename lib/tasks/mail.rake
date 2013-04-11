require File.dirname(__FILE__) + '/../config/environment.rb'
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
    puts RAILS_ROOT
    puts Rails.root
    puts 'start'
    s = File.read(File.join(Rails.root, "app/config/sphinx.conf"))
    unless s.nil?
      puts "test file:#{s}"
    else 
      puts "S IS NULL"
    end
  end 
  
  task :escape => :environment do
    deal = Deal.find("11771")
    puts "#{ERB::Util.url_encode("I just bought this on Qwiqq! #{deal.name} BUY NOW #{deal.price_as_string}")}"
    puts "Finished Rake"
    
  end 
  
  task :send_brandon => :environment do
    user = User.find_by_email("copley.brandon@gmail.com")
    transaction = Transaction.first
    deal = transaction.deal
    Mailer.deal_purchased(user, deal, transaction).deliver
  end
  
  task :send_kyle => :environment do
    user = User.find_by_email("copley.kyle@gmail.com")
    transaction = Transaction.first
    deal = transaction.deal
    Mailer.deal_purchased(user, deal, transaction).deliver
  end
  
end

