Qwiqq::Application.routes.draw do
  
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config

  # public web
  root :to => "deals#index"
  match "merchants",:to => "deals#merchants"
  resources :posts, :only => [:index, :show], :as => "deals", :controller => "deals" do
    get :nearby, :on => :collection
    resource :coupon, :only => [:show], :as => "coupons"
    get "paypal_test", :on => :member
    get "purchase", :on => :member
  end

  resources :users, :only => [:show], :as => "users", :controller => "users" do
    get "purchase", :on => :member
  end
  
  # home routes
  match "about",    :to => "home#about",    :as => :about
  match "terms",    :to => "home#terms",    :as => :terms
  match "fees",     :to => "home#fees",     :as => :fees
  match "privacy",  :to => "home#privacy",  :as => :privacy
  match "blog",     :to => "home#blog",     :as => :blog
  match "download", :to => "home#download", :as => :download
  match "media",    :to => "home#media",    :as => :media
  match 'reports' => 'reports#report'
  match 'mailers/deal_purchased' => 'testing#deal_purchased'
  match 'mailers/deal_sold' => 'testing#deal_sold'
  
  
  # iphone routes
  match "iphone/about",   :to => "home#about",    :as => :iphone_about
  match "iphone/terms",   :to => "home#terms",    :as => :iphone_terms
  match "iphone/fees",   :to => "home#fees",    :as => :iphone_fees
  match "iphone/privacy", :to => "home#privacy",  :as => :iphone_privacy

  match "r", :to => 'home#redirect', :as => :iphone_redirect

  # notifications
  match "notifications/:token", :to => "users#update_notifications", :as => :update_notifications
  
  # api
  namespace "api" do
    resources :users, :only => [:create, :show, :update] do
      get "followers",         :on => :member
      get "following",         :on => :member
      get "following_minimal", :on => :member
      get "friends",           :on => :member
      get "suggested",         :on => :collection
      get "events",            :on => :member
      post "clear_events",     :on => :member
      
      post "following" => "relationships#create"
      delete "following/:target_id" => "relationships#destroy"
      
      resources :likes, :only => [:index]
      resources :comments, :only => [:index]
      resources :invitations, :only => [:index, :create]
      resources :constantcontact, :only => [:create]
      
      resources :deals, :only => [:index] do
        resources :shares, :only => [:create]
      end
      
      post "find_friends" => "friends#find"
      get "facebook_pages", :on => :member
    end
    
    resources :sessions, :only => [:create, :destroy]
    resources :password_resets, :only => [:create, :update]

    
    resources :deals, :only => [:show, :create, :destroy, :update] do
      get "feed",    :on => :collection
      get "popular", :on => :collection
      get "available", :on => :member
      post "repost", :on => :member
      get "events",  :on => :member
      
      resources :likes,         :only => [:index]
      resource :like,           :only => [:create, :destroy] #should merge this with above resource likes
      resources :comments,      :only => [:create, :index]
      resources :transactions,  :only => [:create, :index]
    end
    
    resources :comments, :only => [:destroy]
    resources :transactions, :only => [:destroy]
    resources :venues, :only => [:index]

    # search controller custom methods
    get "search/users" => "search#users", :as => "search_users"
    get "search/deals" => "search#deals", :as => "search_deals"
    get "explore/deals" => "explore#deals", :as => "explore_deals"
    get "explore/popular" => "explore#popular", :as => "explore_popular"

    # TODO deprecate
    get "search/deals/nearby" => "search#deals", :as => "search_deals"
    get "explore/deals/nearby" => "explore#deals", :as => "explore_deals"
    get "search/categories/:name/deals" => "search#category", :as => "search_category"
  end

  # redirect 'deals' to 'posts'
  match "/deals" => redirect("/posts")
  match "/deals/:id" => redirect("/posts/%{id}")
  match "/#_=_" => redirect("/posts")
end