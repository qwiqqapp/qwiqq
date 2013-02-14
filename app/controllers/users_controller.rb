class UsersController < ApplicationController
  def update_notifications
    @user = User.find_by_notifications_token(params[:token])
    redirect_to root_url if @user.nil?
    puts "TEST updating user, sending notification: #{@user.id}"
    @user.update_attributes(:send_notifications => params[:enable] || false)
    render :notifications_disabled, layout: 'basic'
  end

  def show
    @user = User.find(params[:id])
    # TODO pagination
    @deals = @user.deals.sorted.first(20)
  end
  
    def purchase
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
                {:email => 'payments@qwiqq.me',
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
end
