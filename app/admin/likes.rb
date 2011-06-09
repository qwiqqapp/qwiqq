ActiveAdmin.register Like do
  scope :all, :default => true
  scope :today

  index do
    column("User", :sortable => :name) do |like|  
      link_to(like.user.name, [ :admin, like.user ])
    end
    
    column("Deal", :sortable => :name) do |like|  
      link_to(like.deal.name, [ :admin, like.deal ])
    end

    column(:created_at)
    default_actions
  end
end
