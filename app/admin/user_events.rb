ActiveAdmin.register UserEvent do

  
  index do
    id_column   
    column("User", :sortable => :name) do |event|  
      link_to(event.user.name, [ :admin, event.user ]) if event.user
    end
    
    column("Deal", :sortable => :name) do |event|  
      link_to(event.deal.name, [ :admin, event.deal ]) if event.deal
    end  
    
    column(:event_type)
    column :created_at
    column :updated_at
    column :hidden
    
    
    default_actions
  end
  
end
