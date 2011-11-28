Qwiqq::Application.routes.draw do
  
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config

  # public web
  root :to => "deals#index"
  resources :deals, :only => [:index, :show]
  
  # home routes
  match "about",    :to => "home#about",    :as => :about
  match "terms",    :to => "home#terms",    :as => :terms
  match "privacy",  :to => "home#privacy",  :as => :privacy
  match "blog",     :to => "home#blog",     :as => :blog
  match "download", :to => "home#download", :as => :download
  match "media",    :to => "home#media",    :as => :media
  
  # iphone routes
  match "iphone/about",   :to => "home#about",    :as => :iphone_about
  match "iphone/terms",   :to => "home#terms",    :as => :iphone_terms
  match "iphone/privacy", :to => "home#privacy",  :as => :iphone_privacy

  match 'r', :to => 'home#redirect', :as => :iphone_redirect

  # notifications
  match "notifications/:token", :to => "users#update_notifications", :as => :update_notifications
 
  # api
  namespace "api" do
    resources :users, :only => [:create, :show, :update] do

      get "followers", :on => :member
      get "following", :on => :member
      get "friends",   :on => :member
      get "events",    :on => :member
      get "suggested", :on => :collection
      
      post "following" => "relationships#create"
      delete "following/:target_id" => "relationships#destroy"
      
      resources :likes, :only => [:index]
      resources :comments, :only => [:index]
      resources :invitations, :only => [:index, :create]
      
      resources :deals, :only => [:index] do
        resources :shares, :only => [:create]
      end
      
      post "find_friends" => "friends#find"
    end
    
    resources :sessions, :only => [:create, :destroy]
    resources :password_resets, :only => [:create, :update]
    
    resources :deals, :only => [:show, :create, :destroy, :update] do
      get "feed",    :on => :collection
      get "popular", :on => :collection
      post "repost", :on => :member
      get "events",  :on => :member
      
      resources :likes,     :only => [:index]
      resource :like,       :only => [:create, :destroy] #should merge this with above resource likes
      resources :comments,  :only => [:create, :index]
    end

    resources :comments, :only => [:destroy]
    resources :venues, :only => [:index]
    
    # search controller custom methods
    get "search/users"                  => "search#users",    :as => 'search_users'
    get "search/deals/:filter"          => "search#deals",    :as => 'search_deals'   #,    :constraints => { :filter => /\D+/ }
    get "search/categories/:name/deals" => "search#category", :as => 'search_category'#, :constraints => { :name   => /\D+/ }
  end

 
end
