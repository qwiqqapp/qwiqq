Qwiqq::Application.routes.draw do
  
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  # public
  root :to => "deals#index"
  resources :deals, :only => [:index, :show]
  
  namespace "api" do
    resources :users, :only => [:create, :show, :update] do

      get "followers", :on => :member
      get "following", :on => :member
      get "friends",   :on => :member
      
      post "following" => "relationships#create"
      delete "following/:target_id" => "relationships#destroy"
      
      resources :likes, :only => [:index]
      resources :comments, :only => [:index]
      resources :invitations, :only => [:index,:create]
      
      resources :deals, :only => [:index] do
        resources :shares, :only => [:create]
      end
      
      post "find_friends" => "friends#find"
    end
    
    resources :sessions, :only => [:create, :destroy]
    
    resources :deals, :only => [:show, :create, :destroy, :update] do
      get :feed,    :on => :collection
      get :popular, :on => :collection
      
      resources :likes,     :only => [:index]
      resource :like,       :only => [:create, :destroy] #should merge this with above resource likes
      resources :comments,  :only => [:create, :index]
    end

    resources :comments, :only => [:destroy]
    
    # search controller custom methods
    get "search/users"                  => "search#users",    :as => 'search_users'
    get "search/deals/:filter"          => "search#deals",    :as => 'search_deals',    :filter => /\D+/
    get "search/categories/:name/deals" => "search#category", :as => 'search_category', :name   => /\D+/
    match "search/deals"                => redirect("/api/search/deals/newest")
  end
  
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
