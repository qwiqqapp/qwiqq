class CreateCSVJob
  @queue = :notifications
  
  def self.perform(id)
    user = User.find_by_email("mscaria@novationmobile.com")
    Mailer.share_post(user).deliver
    puts "MARKED"

  # allow record not found to silently fail and log
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.info "CreateCSVJob Unable to create CSV file: #{e}"
  end 
end
