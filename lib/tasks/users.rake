namespace :users do
  desc "Clear any #city fields set to an email address" 
  task :clear_city_fields_set_to_email_address => :environment do
    User.find_each do |user|
      user.update_attribute(:city, "") if Qwiqq.email?(user.city)
    end
  end
end

