class CreateCSVJob
  @queue = :notifications
  
  def self.perform(id)
    puts "TRY 0"
    self.csv_export
    puts "MARKED"

  # allow record not found to silently fail and log
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.info "CreateCSVJob Unable to create CSV file: #{e}"
  end 
  
  def csv_export_real
    @deals = Deal.all.sorted    
    @filename = "dealcsv"    
    CSV.open("#{Rails.root.to_s}/tmp/#{@filename}", "wb") do |csv| #creates a tempfile csv
      csv << ["ID", "Name", "Price", "Created At", "Updated At", "Premium", "Lat", "Lon", "Location Name", "Unique Token", "User Photo", "User Photo2x", "4SQ Venue", "Coupon", "Shares Count", "Number of Users Shared"] #creates the header
      csv << ["ID", "Name"]
      @deals.each do |deal|   
        csv << [@deals[0].id.try(:to_s), @deals[0].name]
        csv << [deal.id.try(:to_s), deal.name, deal.price, deal.created_at, deal.updated_at, deal.premium, deal.lat, deal.lon, deal.location_name, deal.unique_token, deal.user.photo.url(:iphone), deal.user.photo.url(:iphone2x), deal.foursquare_venue_name, deal.coupon, deal.shares_count, deal.number_users_shared] #create new line for each item in collection
      end
    end

    #self.update_attribute(:csv_report, File.open("#{Rails.root.to_s}/tmp/#{@filename}"))
    #saves tempfile as paperclip attachment
  end
  
  def csv_export
    puts "TRY 0.0"
    @deal = Deal.all.sorted.limit(1)   
    @filename = "dealcsv" 
    puts "TRY 1"
    CSV.open("#{Rails.root.to_s}/tmp/#{@filename}", "wb") do |csv| #creates a tempfile csv
      puts "TRY 2"
      csv << ["ID", "Name"]
      puts "TRY 3"
      csv << [@deal.id.try(:to_s), @deal.name]
      puts "TRY 4"   
    end
    puts "TRY 5"

    #self.update_attribute(:csv_report, File.open("#{Rails.root.to_s}/tmp/#{@filename}"))
    #saves tempfile as paperclip attachment
  end

end
