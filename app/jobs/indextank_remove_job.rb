class IndextankRemoveJob
  @queue = :indextank
  
  # calling class method on Document as Deal no longer exists
  def self.perform(id)
    Qwiqq::Indextank::Document.remove_doc(id)
  end
end