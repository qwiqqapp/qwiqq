# added as "DealComment" to avoid conflicting with ActiveAdmin::Comment
ActiveAdmin.register Comment, :as => "DealComment" do
#ActiveAdmin.register Comment do
  menu :label => "Comments"
  scope :all, :default => true
  scope :today
  
  filter :body
  filter :created_at
  
  actions :index, :show, :edit, :update, :destroy

  index do
    column("User", :sortable => :name) do |like|  
      link_to(like.user.name, [ :admin, like.user ]) if like.user
    end
    
    column("Deal", :sortable => :name) do |like|  
      link_to(like.deal.name, [ :admin, like.deal ]) if like.deal
    end

    column(:body)
    column(:created_at)

    default_actions
  end
  
  form do |f|
   f.inputs "Details" do
     f.input :body
   end

   f.buttons
  end
end
