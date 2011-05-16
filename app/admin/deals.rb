ActiveAdmin.register Deal do
  
  scope :all, :default => true
  scope :today
  
  filter :name
  filter :price
  filter :created_at
  filter :category, :as => :check_boxes, :collection => proc { Category.all }
  
  index do
    
    column :name
  end
  
  
end
