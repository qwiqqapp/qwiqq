namespace :export do
  
  desc 'export database to events'
  task :events => :environment do
    objects = User.all
    objects += Deal.all(:include => :user)
    objects += Like.all(:include => :user)
    objects += Comment.all(:include => :user)
    objects += Share.all(:include => :user)
    objects += Relationship.all(:include => :user)
    objects += Repost.all(:include => :user)
    
    puts "Located #{objects.size} database objects"
    
    events = objects.map do |obj|
      name  = event_name(obj)
      owner = obj.class == User  ? obj.username : obj.user.username.downcase
      time  = obj.created_at.to_i
      
      { :name => name, :time => time, :owner => owner}
    end
    puts "Creating and writing events to db/events.json"
    
    # puts events.to_json
    File.open(Rails.root + "db/events.json","w") do |f| 
      f.write(JSON.pretty_generate(events))
    end
    puts "Complete"
  end
  
  def event_name(obj)
    name = obj.class.to_s.downcase
    case name
      when 'user'         then "signup"
      when 'deal'         then 'deal post'
      when 'share'        then "#{obj.service} share"
      when 'relationship' then "follow"
      else
        name
    end
  end
  
end