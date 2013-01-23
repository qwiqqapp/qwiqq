class DealsController < ApplicationController
  # caches_action :show, :cache_path => lambda {|c| "home/#{c.find_deal.cache_key}/#{c.ios?}" }


  # TODO either cache action or memoize @deals 
  def index
    @deals = Deal.premium.recent.sorted.popular.first(9)
    render layout: 'home'
  end
  
  def show
    @deal = find_deal
    @events = @deal.events
  end

  # the geoip service was not accurate enough so using suggested users posts as stopgap
  # TODO update nearby to use HTML5 location
  def nearby
    lat, lon = find_location
    if lat and lon
      @deals =  Deal.filtered_search(:lat => lat, :lon => lon, :range => Deal::MAX_RANGE*2).compact.first(6)
    else
      @deals = []
    end
    
    render layout: false
  end
  
  def find_deal
    @deal ||= Deal.find(params[:id])
  end
  
  def destroy
    @deal = current_user.deals.find(params[:id])
    @deal.destroy
    respond_with @deal
  end
  
  def paypal_test
    deal = Deal.find(params[:id])
    puts "AJAX WORKED PARAMS#{deal.price}"
    gateway =  ActiveMerchant::Billing::PaypalAdaptivePayment.new( 
                  :login => "acutio_1313133342_biz_api1.gmail.com",
                  :password => "1255043567",
                  :signature => "Abg0gYcQlsdkls2HDJkKtA-p6pqhA1k-KTYE0Gcy1diujFio4io5Vqjf",
                  :appid => "APP-80W284485P519543T" )
                
    recipients = [{:email => 'copley.brandon@gmail.com',
                 :amount => 0.50,
                 :primary => true},
                {:email => 'john@qwiqq.me',
                 :amount => 0.50,
                 :primary => false}
                 ]
    response = gateway.setup_purchase(
      :currency_code => deal.currency,
      :return_url => "http://www.google.com",
      :cancel_url => "http://www.yahoo.com",
      :ipn_notification_url => "http://api.qwiqq.me//api/deals/10463/transactions?buyer_id=13527&sandbox=false",
      :receiver_list => recipients
  )

  # For redirecting the customer to the actual paypal site to finish the payment.
  redirect_to (gateway.redirect_url_for(response["payKey"]))

  end

  
  private
  def find_location
    if Rails.env.development?
      ip = '96.49.202.116' #for easy testing
    else
      ip = request.remote_ip
    end
    
    response = HTTParty.get("http://qwiqq-geoip.heroku.com/location.json?ip=#{ip}")
    if response and response.code == 200
      [ response["latitude"], response["longitude"] ]
    end
  end
end

