# replace \s with ''
# replace . with '_'
# replace _+ with '_'
# else remove non letters, numbers and _ 

# fallback = firstname + lastname
# default to qwiqq324

namespace :users do
  
  def clean(u)
    return "username clean, skipping: #{u.username}" if u.username == cleaner(u.username)
    
    puts "#{u.id}: #{u.username}"
    # cleaned
    u.username = cleaner(u.username)
    return " + user #{u.id} cleaned: #{u.username}" if u.save
    
    # fname+lname
    u.username = cleaner("#{u.first_name}#{u.first_name}")
    return " + username set to fname+lname: #{u.username}" if u.save
    
    # default
    u.username = "qwiqq#{Random.rand(1-500)}"
    u.save
    "user defaulted to #{u.username}"
  end
  
  def cleaner(name)
    name.gsub(/\s|\./, '_').gsub(/\_+/, '_').gsub(/\W/, '')
  end
  
  desc 'batch clean all usernames to be letters numbers and _ only'
  task :username_cleaner => :environment do
    User.all.each {|u| puts clean(u)}
  end
end