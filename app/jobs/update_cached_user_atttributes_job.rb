class UpdateCachedUserAttributesJob
  @queue = :general
  
  def self.perform(user_id)
    user = User.find(user_id) rescue nil
    return if user.nil?

    user.events_created.find_each do |event|
      event.update_cached_attributes and event.save
    end
  end
end

