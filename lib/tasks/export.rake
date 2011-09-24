namespace :export do
  
  desc 'batch add all deals to indextank'
  task :events => :environment do
    deals     = Deal.all(:include => :user)
    likes     = Like.all(:include => :user)
    comments  = Comment.all(:include => :user)



  end
end