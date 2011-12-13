class CreateEventJob
  @queue = :events
  
  def self.perform(id, klass)
    #find related object and construct related event
  end
end
