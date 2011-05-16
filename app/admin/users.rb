ActiveAdmin.register User do
  
  scope :all, :default => true
  scope :today
  
  filter :name
  filter :email
  filter :city
  filter :country
  filter :created_at
  
  index do
    column("") {|user| link_to(image_tag(user.photo.url(:admin)), admin_users_path(user))}
    column("Name", :sortable => :name) {|user|  link_to user.name, admin_user_path(user)}
    column :email
    column :country
    column :city
    column("Joined", :sortable => :created_at){|user| user.created_at.to_s(:short) }
    column("Edited", :sortable => :updated_at){|user| user.updated_at.to_s(:short) }
  end
  
  show :title => :name do
      panel "Deal History" do
        table_for(user.deals) do
          column("") {|deal| link_to(image_tag(deal.photo.url(:admin)), admin_deals_path(deal))}
          column("Name", :sortable => :name) {|deal| link_to deal.name, admin_deal_path(deal) }
          column("Date", :sortable => :created_at ){|deal| pretty_format(deal.created_at) }
          column("Price")                   {|deal| number_to_currency deal.price }
        end
      end
      
      panel "Comment History" do
        table_for(user.comments) do
          column("Comment") {|comment| comment.body }
          column("Date", :sortable => :created_at ){|deal| pretty_format(deal.created_at) }
        end
      end
      
      active_admin_comments
    end

  sidebar "User Details", :only => :show do
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
