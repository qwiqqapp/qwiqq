namespace :export do
  
  desc 'export database to events'
  task :events => :environment do
    events  = []
    objects = []
    
    objects += Deal.all(:include => :user)
    objects += Like.all(:include => :user)
    objects += Comment.all(:include => :user)
    
    puts "Located #{objects.size} database objects"
    
    objects.each do |obj|
      events << { :name => "#{obj.class.to_s.downcase} create",
                  :time => obj.created_at.to_i,
                  :owner => obj.user.username.downcase }
    end
    puts "Creating and writing events to db/events.json"
    
    # puts events.to_json
    File.open(Rails.root + "db/events.json","w") {|f| f.write(JSON.pretty_generate(events))}
    puts "Complete"
  end
end