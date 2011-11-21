ActiveAdmin.register User do
  
  scope :all, :default => true
  scope :today
  scope :suggested
  
  filter :first_name
  filter :last_name
  filter :username
  filter :email
  filter :city
  filter :country
  filter :created_at
  
  index do
    column("") do |user| 
      link_to(image_tag(user.photo.url(:iphone)), [:admin, user])
    end
    
    column("Name", :sortable => :last_name) do |user|  
      link_to("#{user.first_name} #{user.last_name}", [:admin, user])
    end
    
    column :email
    
    column('Location') do |l|
      "#{l.country}, #{l.city}" unless l.country.blank? or l.city.blank?
    end

    column("Joined", :sortable => :created_at){|user| user.created_at.to_s(:short) }
  end
  
  show :title => :name do
    panel "Deal History (#{user.deals.size})" do
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
    
    panel "Liked Deals (#{user.liked_deals.size})" do
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
        column("Deal") {|c| link_to c.deal.name, [:admin, c.deal] }
        column("Comment") {|c| c.body }
        column("Date", :sortable => :created_at ){|deal| pretty_format(deal.created_at) }
      end
    end
    
    active_admin_comments
  end

  sidebar "Photo", :only => [:show, :edit] do
    image_tag(user.photo.url(:iphone_zoom))
  end
  
  sidebar "Details", :only => :show do
    attributes_table_for user, :first_name, :last_name, :username, :email, :country, :city, :created_at, :suggested
  end
  
  form(:html => {:multipart => true}) do |f|
   f.inputs "Details" do
     f.input :first_name
     f.input :last_name
     f.input :username
     f.input :email
     f.input :city
     f.input :country, :as => :string
     f.input :photo, :as => :file
     f.input :suggested
   end
   
   f.buttons
  end
  
end
