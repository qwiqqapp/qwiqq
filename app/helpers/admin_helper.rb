module AdminHelper
  
  def row_classes(object)
    c = []
    c << "new"        if object.respond_to?('created_at') && Time.now - object.created_at < 7200 #last 2 hours
    c << "featured"   if object.respond_to?('featured?')  && object.featured?
    c.join(' ')
  end
end