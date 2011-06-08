# added as "DealComment" to avoid conflicting with ActiveAdmin::Comment
ActiveAdmin.register Comment, :as => "DealComment" do
  scope :all, :default => true
  scope :today

  filter :user

  index do
    column("User", :sortable => :name) do |like|  
      link_to(like.user.name, [ :admin, like.user ])
    end
    
    column("Deal", :sortable => :name) do |like|  
      link_to(like.deal.name, [ :admin, like.deal ])
    end

    column(:body)
    column(:created_at)

    default_actions
  end
end
