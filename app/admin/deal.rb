#this exists purely for the dashboard
ActiveAdmin.register Deal do
  #ActiveAdmin.register Deal, :as => "Deals" do
  
  show :title => 'Posts'
  
  menu :label => "Posts"
  #menu false
  
  actions :index, :show, :edit, :update, :destroy
  
  scope :all, :default => true
  scope :today
  scope :recent
  scope :premium
  scope :coupon
  scope :most_shared
  
  filter :name
  filter :foursquare_venue_name
  filter :price
  filter :created_at
  filter :premium
  filter :deals_num
  filter :category, :as => :check_boxes, :collection => proc { Category.all }
  
  csv do
    column("ID"){|deal| deal.id.try(:to_s)}
    column("Name"){ |deal| deal.name }
    column("Price"){ |deal| deal.price_as_string }
    column(:created_at)
    column(:updated_at)
    column(:premium)
    column(:lat)
    column(:lon)
    column("Location Name") {|deal| deal.location_name}
    column("Unique Token") {|deal| deal.unique_token}
    column("User Photo") {|deal| deal.user.photo.url(:iphone)}
    column("User Photo2x") {|deal| deal.user.photo.url(:iphone2x)}
    column('4SQ Venue'){|d| d.foursquare_venue_name}
    column :coupon
    column :shares_count
    column :number_users_shared
    column :for_sale_on_paypal
    column :num_for_sale
    column :num_left_for_sale
    column :paypal_email
    column :hidden
  end
    
  index do
    column("") do |deal| 
      link_to(image_tag(deal.photo.url(:iphone_list)), [:admin, deal])
    end
    
    column("Name", :sortable => :name) do |deal|
      link_to(deal.name, [:admin, deal])
    end
    column("Category") {|deal| status_tag(deal.try(:category).try(:name)) }
    column('Venue (4SQ)') {|d| link_to(d.foursquare_venue_name, "http://foursquare.com/v/#{d.foursquare_venue_id}") if d.foursquare_venue_name}

    column("Premium", :sortable => :premium){|deal| deal.premium ? status_tag("Premium") : nil  }

    column :likes_count
    column :comments_count
    column :shares_count
    column :number_users_shared
    
    column("User", :sortable => :user_id) {|deal| link_to(deal.user.best_name, admin_user_path(deal.user))}
    column("Price", :sortable => :price) {|deal| deal.price ? deal.price_as_string : "" }
    
    column :created_at
    
    column :paypal_email
    column :for_sale_on_paypal
    column :num_for_sale
    column :num_left_for_sale
    column :hidden
    
    default_actions
  end
  
  form(:html => {:multipart => true}) do |f|
   f.inputs "Details" do
     f.input :name
     f.input :currency
     f.input :price, :hint => "Stored in cents. Example: 1000c = $10.00"
     f.input :category
     f.input :photo, :as => :file
     f.input :premium
     f.input :coupon
     f.input :coupon_count
     f.input :paypal_email
     f.input :for_sale_on_paypal
     f.input :num_for_sale
     f.input :num_left_for_sale
     f.input :hidden
   end
   
   f.inputs "Location" do
     f.input :lat
     f.input :lon     
     f.input :foursquare_venue_id, :hint => "http://foursquare.com/v/4d41f6341da9a09377485d3d"
     f.input :foursquare_venue_name
     f.input :located
  end 
     
   f.buttons
  end
  
  show :title => :name do
    panel "Comments (#{deal.comments.size})" do
      table_for(deal.comments) do
        column("") {|c| link_to(image_tag(c.user.photo.url(:iphone)), admin_user_path(c.user))}
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
    image_tag(deal.photo.url(:iphone_explore_2x))
  end
    
  sidebar "Details (raw data)", :only => :show do
    attributes_table_for deal, :name, :price, :lat, :lon,  :likes_count, :comments_count, :premium, :created_at, :updated_at, :coupon, :coupon_count, :number_users_shared, :for_sale_on_paypal, :num_for_sale, :num_left_for_sale, :hidden
  end
end
