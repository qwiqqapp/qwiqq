namespace :feedlets do
  desc 'batch create all feedlets'
  task :create => :environment do
    Deal.all.each do |d|
      d.populate_feed
    end
  end
  
  desc 'trim feedlets for each user (max = 100)'
  task :trim => :environment do
    User.find_each do |u| 
      puts 'cleaning up feedlets for user: ' + user.username
      Feedlet.where(:user_id => u.id).order('timestamp').offset(100).destroy_all
    end
  end
end

