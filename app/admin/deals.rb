ActiveAdmin.register Deal do
  
  actions :index, :show, :edit, :update, :destroy
  
  scope :all, :default => true
  scope :today
  
  filter :name
  filter :price
  filter :created_at
  filter :premium
  filter :category, :as => :check_boxes, :collection => proc { Category.all }
    
  index do
    column("") do |deal| 
      link_to(image_tag(deal.photo.url(:admin_sml)), [:admin, deal])
    end
    
    column("Name", :sortable => :name) do |deal|
      link_to(deal.name, [:admin, deal])
    end
    
    column('Location') {|d| link_to d.location_name, "http://maps.google.com/maps?q=#{d.name}@#{d.lat},#{d.lon}"}
    
    column("Category") {|deal| status_tag(deal.try(:category).try(:name)) }
    column("Premium", :sortable => :premium){|deal| deal.premium ? status_tag("Premium") : nil  }
    
    column("Date", :sortable => :created_at){|deal| deal.created_at.to_s(:short) }
    column("User", :sortable => :user_id) {|deal| link_to(deal.user.name, admin_user_path(deal.user))}
    column("Price", :sortable => :price) {|deal| "$#{(deal.price.to_f/100)}" }
  end
  
  form(:html => {:multipart => true}) do |f|
   f.inputs "Details" do
     f.input :name
     f.input :price
     f.input :category
     f.input :lat
     f.input :lon
     f.input :photo, :as => :file
     f.input :premium
   end

   f.buttons
  end
  
  
  show :title => :name do
      panel "Deal Comments (#{deal.comments.size})" do
        table_for(deal.comments) do
          column("") {|c| link_to(image_tag(c.user.photo.url(:admin_med)), admin_user_path(c.user))}
          column("User") {|c| link_to(c.user.name, [:admin, c.user])}
          column('Comment'){|c| c.body}
          column(:created_at)
          column("") do |comment| 
            links  = link_to("View", admin_deal_comment_path(comment), :class => "member_link view_link")
            links += link_to("Edit", edit_admin_deal_comment_path(comment))
            links
          end
        end
      end
      
      panel "Like History (#{deal.likes.size})" do
        table_for(deal.likes) do
          column("User") {|c| link_to(c.user.name, [:admin, c.user])}
          column :created_at
        end
      end
      
      active_admin_comments
    end
    
    
  sidebar "Photo", :only => [:show, :edit] do
    image_tag(deal.photo.url(:admin_lrg))
  end
    
  sidebar "Details", :only => :show do
    attributes_table_for deal, :name, :price, :lat, :lon,  :like_count, :comment_count, :premium, :created_at, :updated_at
  end
end
