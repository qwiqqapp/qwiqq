ActiveAdmin.register User do
  
  scope :all, :default => true
  scope :today
  
  filter :name
  filter :email
  filter :city
  filter :country
  filter :created_at
  
  
  index do
    column :name
    column :email
    column :country
    column :city
    column :created_at
    default_actions
  end
  
  
  show :title => :name do
      panel "Deal History" do
        table_for(user.deals) do
          column("Deal", :sortable => :id) {|deal| link_to "##{deal.id}", admin_deal_path(deal) }
          column("Date", :sortable => :created_at ){|deal| pretty_format(deal.created_at) }
          column("Price")                   {|deal| number_to_currency deal.price }
        end
      end
      active_admin_comments
    end

  sidebar "User Details", :only => :show do
    attributes_table_for user, :name, :email, :country, :city, :created_at
  end
  
  
  form do |f|
   f.inputs "Details" do
     f.input :name
     f.input :email
     f.input :city
     f.input :country
   end

   f.buttons
 end
  
  
end
