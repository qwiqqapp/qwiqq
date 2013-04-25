ActiveAdmin.register User do
  
  scope :all, :default => true
  scope :today
  scope :suggested
  scope :connected_to_facebook
  scope :connected_to_twitter
  scope :connected_to_foursquare    
  
  filter :first_name
  filter :last_name
  filter :username
  filter :email
  filter :city
  filter :country
  filter :created_at
  
  index do
    column("") do |user| 
       link_to(image_tag(user.photo.url(:iphone_small)), [:admin, user])
    end
    id_column     
    column :first_name
    column :last_name
    column :username
    column :email
    column :country
    column :city
    
    column :followers_count
    column :following_count
    column "Posts Count", :deals_num
    column :comments_count
    column :likes_count
    
    column :num_for_sale_on_paypal
    
    column :created_at
    column :updated_at
    
    default_actions
  end
  
  show :title => :name do
    panel "Post History (#{user.deals.size})" do
      table_for(user.deals) do
        column("") do |deal| 
          link_to(image_tag(deal.photo.url(:iphone_grid)), [:admin, deal])
        end
        column("Name", :sortable => :name) do |deal|  
          link_to(deal.name, [:admin, deal])
        end
        column("Category") {|deal| status_tag(deal.try(:category).try(:name)) }
        column("Date", :sortable => :created_at){|deal| deal.created_at.to_s(:short) }
        column("Price", :sortable => :price) {|deal| deal.price ? number_to_currency(deal.price.to_f/100) : "" }
      end
    end
    
    panel "Liked Posts (#{user.liked_deals.size})" do
      table_for(user.liked_deals) do
        column("") do |deal| 
          link_to(image_tag(deal.photo.url(:iphone_grid)), [:admin, deal])
        end
        column("Name", :sortable => :name) do |deal|  
          link_to(deal.name, [:admin, deal])
        end
        column("Category") {|deal| status_tag(deal.try(:category).try(:name)) }
        column("Date", :sortable => :created_at){|deal| deal.created_at.to_s(:short) }
        column("Price", :sortable => :price) {|deal| number_to_currency deal.price }
      end
    end
      
    panel "Comment History (#{user.comments.size})" do
      table_for(user.comments) do
        column("") do |c| 
          link_to(image_tag(c.deal.photo.url(:iphone_grid)), [:admin, c.deal])
        end
        column("Post") {|c| link_to c.deal.name, [:admin, c.deal] }
        column("Comment") {|c| c.body }
        column("Date", :sortable => :created_at ){|deal| pretty_format(deal.created_at) }
      end
    end
    
    active_admin_comments
  end

  sidebar "Photo", :only => [:show, :edit] do
    image_tag(user.photo.url(:iphone_profile_2x))
  end
  
  sidebar "Details", :only => :show do
    attributes_table_for user, :first_name, 
                                :last_name, 
                                :username, 
                                :email, 
                                :country, 
                                :city, 
                                :created_at, 
                                :facebook_id,
                                :twitter_id,
                                :foursquare_id,
                                :suggested,
                                :send_notifications,
                                :website,
                                :phone
  end
  
  form(:html => {:multipart => true}) do |f|
   f.inputs "Details" do
     f.input :first_name
     f.input :last_name
     f.input :username
     f.input :email
     if f.object.id.nil?
       f.input :password
       f.input :confirm_password
     end
     f.input :city
     f.input :phone
     f.input :website
     f.input :bio     
     f.input :country, :as => :string
     f.input :photo, :as => :file
     f.input :suggested
   end
   
   f.buttons
  end
  
end
