namespace :feedlets do
  desc 'batch refresh all feedlets'
  task :refresh => :environment do
    puts "- Remove all feedlets..."
    Feedlet.destroy_all
    puts "- Feedlets removed."
    
    Deal.find_each do |d| 
      puts "+ Populating feeds for deal #{d.id}: #{d.name}"
      d.populate_feed
    end
  end
  
  desc 'trim feedlets for each user (max = 100)'
  task :trim => :environment do
    User.find_each do |u| 
      puts 'cleaning up feedlets for user: ' + u.username
      Feedlet.where(:user_id => u.id).order('timestamp').offset(100).destroy_all
    end
  end
end

