namespace :category do
  
  desc 'update categories names (WARNING, will remove categories if not on new_names list)'
  task :update => :environment do
    new_names = %w(deal food fashion beauty ae sport tech home car)
    current_names = Category.all.map(&:name)
    
    # create new categories
    (new_names - current_names).each do |name|
      Category.create!(:name => name)
      puts ' + added category with name: ' + name
    end
    
    # remove old categories and their deals
    Category.find_each do |c|
      unless new_names.include?(c.name)
        puts " - removing deals in category #{c.name}"
        c.deals.destroy_all
        puts " - removing category #{c.name}"
        c.destroy
        puts " - removed category #{c.name} and attached deals"
      end
    end
    
  end
end