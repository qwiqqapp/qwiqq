class CouponsController < ApplicationController
  layout false
  before_filter :find_deal
  attr_reader :deal
  helper_method :deal, :redeemed?

  def show
    @redeemed = deal.redeem_coupon!
  end

  def redeemed?
    @redeemed
  end
  
  def paypal_test
    puts "AJAX WORKED"
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
    :return_url => "http://www.google.com",
    :cancel_url => "http://www.yahoo.com",
    :ipn_notification_url => "http://api.qwiqq.me//api/deals/10463/transactions?buyer_id=13527&sandbox=false",
    :receiver_list => recipients
  )

  # For redirecting the customer to the actual paypal site to finish the payment.
  redirect_to (gateway.redirect_url_for(response["payKey"]))

  end


private
  def find_deal
    @deal ||= begin
      deal = Deal.find(params[:deal_id])
      # redirect if the deal doesn't have a coupon
      unless deal.present? and deal.coupon?
        redirect_to root_url and return
      end
      deal
    end
  end
end
