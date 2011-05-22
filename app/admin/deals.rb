ActiveAdmin.register Deal do
  
  scope :all, :default => true
  scope :today
  
  filter :name
  filter :price
  filter :created_at
  filter :category, :as => :check_boxes, :collection => proc { Category.all }
  
  index do
    column("") do |deal| 
      link_to(image_tag(deal.photo.url(:admin_sml)), [:admin, deal])
    end
    
    column("Name", :sortable => :name) do |deal|  
      link_to(deal.name, [:admin, deal])
    end
    
    column("Category") {|deal| status_tag(deal.try(:category).try(:name)) }
    column("Premium", :sortable => :premium){|deal| deal.premium ? status_tag("Premium") : nil  }
    
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
     f.input :premium
   end
   
   f.buttons
  end
  
  
  show :title => :name do
      panel "Comment History (#{deal.comments.size})" do
        table_for(deal.comments) do
          column("") {|c| link_to(image_tag(c.user.photo.url(:admin_med)), admin_user_path(c.user))}
          column("User") {|c| link_to(c.user.name, [:admin, c.user])}
          column('Comment'){|c| c.body}
          column :created_at
        end
      end
      active_admin_comments
    end
    
    
  sidebar "Photo", :only => [:show, :edit] do
    image_tag(deal.photo.url(:admin_lrg))
  end
    
  sidebar "Details", :only => :show do
    attributes_table_for deal, :name, :price, :location, :created_at, :updated_at, :premium
  end
end
