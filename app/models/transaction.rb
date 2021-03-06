class Transaction < ActiveRecord::Base
  belongs_to :user, :counter_cache => true, :touch => true
  belongs_to :deal, :counter_cache => true, :touch => true
  
  validates_presence_of :deal, :paypal_transaction_id

  default_scope :order => 'created_at desc'
  scope :today, lambda { where('DATE(created_at) = ?', Date.today)}
  
    def as_json(options={})
    {
      :transaction_id           => id.try(:to_s),
      :paypal_transaction_id    => paypal_transaction_id,
      :buyer                    => { :user_id   => user.id.try(:to_s),
                                     :name      => user.name,
                                     :user_name => user.username,
                                     :photo     => user.photo.url(:iphone),
                                     :photo_2x  => user.photo.url(:iphone2x)},
      :seller                   => { :user_id   => deal.user.id.try(:to_s),
                                     :name      => deal.user.name,
                                     :user_name => deal.user.username,
                                     :photo     => deal.user.photo.url(:iphone),
                                     :photo_2x  => deal.user.photo.url(:iphone2x)},
      :deal                     => { :deal_id => deal.id.try(:to_s),
                                     :name    => deal.name,
                                     :photo_grid     => deal.photo.url(:iphone_grid),
                                     :photo_grid_2x  => deal.photo.url(:iphone_grid_2x)}
      
    }
  end
  
  def create_sold_event(params)
    puts "inside create_sold_event"
    events.create(
      :event_type => "sold", 
      :metadata => { :body => "sold" }, 
      :deal => deal,
      :user => user, 
      :transaction => self,
      :created_by => user)
  end

end
