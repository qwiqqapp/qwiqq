require 'adaptive_pay/interface'

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
  
  def test_ajax
    puts "TESTED AJAX"
    interface = AdaptivePay::Interface.new
    response = interface.request_payment do |request|
      request.currency_code = "USD"

      request.cancel_url = "http://example.com/cancelled_payment"        # this is where the user will be redirected should he cancel the payment
      request.return_url = "http://example.com/completed_payment"       # and here should the payment be succesful
      request.ipn_notification_url = "http://example.com/ipn_callback"      

      request.add_recipient :email => "copley.brandon@gmail.com",
                          :amount => 100,
                         :primary => false

      request.add_recipient :email => "michaelscaria@yahoo.com",
                          :amount => 10,
                          :primary => true
    end
    
    if response.created?
      # the payment has been setup successfully, now the user will need to be redirected to the Paypal site:
      redirect_to response.payment_page_url
    else
      # the payment could not be setup, most likely because of a missing parameter or validation error
      # the array of errors reported by the service can be retrieved using:
      response.errors
    end
    
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
