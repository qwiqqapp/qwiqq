namespace :export do
  
  desc 'export users'
  task :users => :environment do
    users = User.all
    puts "Located #{users.size} Users for export"
    
    result = users.map do |u|
      { :id => u.id, :username => u.username, :name => u.name, :email => u.email, :time => u.created_at.to_i}
    end

    write_json('users', result)
  end
  
  desc 'export database to events'
  task :events => :environment do
    
    objects = User.all
    objects += collect_objects([Deal, Like, Comment, Share, Relationship, Repost])
    puts "Located #{objects.size} database objects"
    
    result = objects.map do |obj|
      name  = event_name(obj)
      owner = obj.class == User  ? obj.username : obj.user.username.downcase
      time  = obj.created_at.to_i
      { :name => name, :time => time, :owner => owner}
    end
    
    write_json('events', result)
  end
  
  def collect_objects(class_names)
    class_names.map do |c|
      c.all(:include => :user)
    end.flatten
  end
  
  def write_json(name, objects)
    puts "Writing events to db/export/#{name}.json"
    File.open(Rails.root + "db/export/#{name}.json","w") do |f| 
      f.write(JSON.pretty_generate(objects))
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