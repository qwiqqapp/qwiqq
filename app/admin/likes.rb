ActiveAdmin.register Like do
  scope :all, :default => true
  scope :today
  
  actions :index, :destroy

  index do
    column("User", :sortable => :name) do |like|  
      link_to(like.user.name, [:admin, like.user]) if like.user
    end
    
    column("Deal", :sortable => :name) do |like|  
      link_to(like.deal.name, [ :admin, like.deal ]) if like.deal
    end

    column(:created_at)
    
    column(""){|like| link_to("Delete", [:admin, like], :method => 'delete')}
  end
end
