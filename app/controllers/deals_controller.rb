class DealsController < ApplicationController
  # caches_action :show, :cache_path => lambda {|c| "home/#{c.find_deal.cache_key}/#{c.ios?}" }


  # TODO either cache action or memoize @deals 
  def index
    @deals = Deal.premium.recent.sorted.popular.first(9)
    render layout: 'home'
  end
  
  def merchants
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
                  :login => "john_api1.qwiqq.me",
                  :password => "3JDZZY9VYXB6Q5TZ",
                  :signature => "AFcWxV21C7fd0v3bYYYRCpSSRl31A1s7XP94yCP.a3BcpSz3430646nm",
                  :appid => "APP-9A930492654909518" )
    
    amt = deal.price*0.00035
    amt = if amt<0.01 
            0.01
          else
            amt
          end
    puts "PAYEE:'#{deal.paypal_email}'"
    puts "#{deal.price} + #{amt}"
         #[{:email => "#{deal.user.email}",
    recipients = [{:email => "#{deal.paypal_email}",
                 :amount => (deal.price * 0.01).round(2),
                 :primary => true},
                {:email => 'john@qwiqq.me',
                 :amount => amt.round(2),
                 :primary => false}
                 ]
                 
    response = gateway.setup_purchase(
      :currency_code => deal.currency,
      :return_url => "http://api.qwiqq.me/posts/#{deal.id}",
      :cancel_url => "http://api.qwiqq.me/posts/#{deal.id}",
      :ipn_notification_url => "http://api.qwiqq.me/api/deals/#{deal.id}/transactions?sandbox=false",
      :receiver_list => recipients
  )
  puts "RESPONSE:#{response}"
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

