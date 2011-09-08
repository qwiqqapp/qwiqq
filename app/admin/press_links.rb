ActiveAdmin.register PressLink do
  scope :all, :default => true
  
  filter :created_at
  
  

  index do
    column :publication_name
    column :article_title
    column :url
    column :published_at

    
    column(""){|press_link| link_to("Delete", [:admin, press_link], :method => 'delete')}
  end

  form do |f|
   f.inputs "Details" do
     f.input :publication_name
     f.input :article_title, :as => :string
     f.input :url
     f.input :published_at, :as => :date
   end
   f.buttons
  end
  
end
