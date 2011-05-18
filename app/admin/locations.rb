ActiveAdmin.register Location do
  
  filter :name
  filter :country
  filter :state
  filter :city
  filter :created_at
  
  index do
    column :name
    column :country
    column :state
    column :city
    column :postcode
    column('Map') {|l| link_to 'Map', "http://maps.google.com/maps?q=#{l.name}@#{l.lat},#{l.long}"}
  end
  
  
  
end
