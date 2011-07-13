
namespace :indextank do
  
  desc 'batch add all deals to indextank'
  task :batch_add => :environment do
    deals = Deal.all
    puts "Adding #{deals.size} deals to indextank..."
    
    deals.each_with_index do |deal,i|
      puts "#{i}  + Deal #{deal.id} #{deal.name}"
      deal.indextank_doc.add
    end
  end
end