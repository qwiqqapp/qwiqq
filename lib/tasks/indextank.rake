namespace :indextank do
  
  desc 'batch add all deals to indextank'
  task :batch_add => :environment do
    deals = Deal.all
    puts "Adding #{deals.size} deals to indextank..."
    
    deals.each_with_index do |deal,i|
      puts "#{i}  + Deal #{deal.id} #{deal.name} added"
      deal.indextank_doc.add
    end
  end

  desc 'batch update all deals to indextank'
  task :batch_update => :environment do
    deals = Deal.all
    puts "Update #{deals.size} deals to indextank..."
    
    deals.each_with_index do |deal,i|
      puts "#{i}  + Deal #{deal.id} #{deal.name} updated"
      deal.indextank_doc.sync
    end
  end
  
  desc 'batch remove all deals to indextank'
  task :batch_remove => :environment do
    deals = Deal.all
    puts "Removing #{deals.size} deals to indextank..."
    
    deals.each_with_index do |deal,i|
      puts "#{i}  + Deal #{deal.id} #{deal.name} removed"
      deal.indextank_doc.remove
    end
  end
end
