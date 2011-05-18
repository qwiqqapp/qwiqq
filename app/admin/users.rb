ActiveAdmin.register User do
  
  scope :all, :default => true
  scope :today
  
  filter :name
  filter :email
  filter :city
  filter :country
  filter :created_at
  
  index do
    column("") do |user| 
      link_to(image_tag(user.photo.url(:admin_sml)), [:admin, user])
    end
    
    column("Name", :sortable => :name) do |user|  
      link_to(user.name, [:admin, user])
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
            link_to(image_tag(deal.photo.url(:admin_med)), [:admin, deal])
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
            link_to(image_tag(c.deal.photo.url(:admin_med)), [:admin, c.deal])
          end
          column("Deal") {|c| link_to c.deal.name, [:admin, c.deal] }
          column("Comment") {|c| c.body }
          column("Date", :sortable => :created_at ){|deal| pretty_format(deal.created_at) }
        end
      end
      
      active_admin_comments
    end

  sidebar "Photo", :only => [:show, :edit] do
    image_tag(user.photo.url(:admin_lrg))
  end
  
  sidebar "Details", :only => :show do
    attributes_table_for user, :name, :email, :country, :city, :created_at
  end
  
  
  form(:html => {:multipart => true}) do |f|
   f.inputs "Details" do
     f.input :name
     f.input :email
     f.input :password
     f.input :password_confirmation
     f.input :city
     f.input :country, :as => :string
     f.input :photo, :as => :file
   end
   
   f.buttons
  end
  
  
end
