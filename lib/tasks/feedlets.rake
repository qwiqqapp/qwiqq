namespace :feedlets do
  desc 'batch create all feedlets'
  task :create => :environment do
    Deal.all.each do |d|
      d.populate_feed
    end
  end
end

