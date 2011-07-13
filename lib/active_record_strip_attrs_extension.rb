module ActiveRecordStripAttrsExtension
  def strip_attrs(*attributes)
    attributes.each do |attribute|
      before_validation do |record|
        record.send("#{attribute}=", record.send("#{attribute}_before_type_cast").to_s.strip) if record.send(attribute)
      end
    end
  end
end

::ActiveRecord::Base.class_eval do
  extend ActiveRecordStripAttrsExtension
end