namespace :deals do
  desc "Clean deal location fields"
  task :clean_location_name => :environment do
    Deal.find_each do |deal|
      next unless location_name = deal.location_name
      if location_name[0] == "-"
        deal.update_attribute(:location_name, location_name.slice(1..-1))
      end
    end
  end
end

