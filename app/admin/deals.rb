ActiveAdmin.register Deal do
  
  scope :all, :default => true
  scope :today
  
  filter :name
  filter :price
  filter :created_at
  filter :category, :as => :check_boxes, :collection => proc { Category.all }
  
  index do
    column("") {|deal| link_to(image_tag(deal.photo.url(:admin)), admin_deals_path(deal))}
    column("Name", :sortable => :name) {|deal|  link_to deal.name, admin_deal_path(deal)}
    column("Category") {|deal| status_tag(deal.try(:category).try(:name)) }
    column("Date", :sortable => :created_at){|deal| deal.created_at.to_s(:short) }
    column("User", :sortable => :user_id) {|deal| link_to(deal.user.name, admin_user_path(deal.user))}
    column("Price", :sortable => :price) {|deal| number_to_currency deal.price }
  end
  
  form(:html => {:multipart => true}) do |f|
   f.inputs "Details" do
     f.input :name
     f.input :price
     f.input :category
     f.input :location
     f.input :photo, :as => :file
   end
   
   f.buttons
  end
  
  
  show :title => :name do
      panel "Deal Comments" do
        table_for(deal.comments) do
          column("") {|c| link_to(image_tag(c.user.photo.url(:admin)), admin_user_path(c.user))}
          column('Comment'){|c| c.body}
          column :created_at
        end
      end
      active_admin_comments
    end
    
  sidebar "Deal Details", :only => :show do
    attributes_table_for deal, :name, :price, :location, :created_at
  end
end
