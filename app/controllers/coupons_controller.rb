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
    http = Net::HTTP.new('https://svcs.paypal.com', 80)
    path = '/AdaptivePayments/Pay'

    data = '{\"actionType\":\"PAY\", \"currencyCode\":\"USD\", \"receiverList\":{\"receiver\":[{\"amount\":\"1.00\",\"email\":\"rec1_1312486368_biz@gmail.com\"}]}, \"returnUrl\":\"http://www.google.com\", \"cancelUrl\":\"http://www.facebook.com\", \"requestEnvelope\":{\"errorLanguage\":\"en_US\", \"detailLevel\":\"ReturnAll\"}}'
    headers = {
      'Content-Type' => 'application/x-www-form-urlencoded',
      "X-PAYPAL-SECURITY-USERID" => "caller_1312486258_biz_api1.gmail.com",
      "X-PAYPAL-SECURITY-PASSWORD" => "1312486294",
      "X-PAYPAL-SECURITY-SIGNATURE" => "AbtI7HV1xB428VygBUcIhARzxch4AL65.T18CTeylixNNxDZUu0iO87e",
      "X-PAYPAL-REQUEST-DATA-FORMAT" => "JSON",
      "X-PAYPAL-RESPONSE-DATA-FORMAT" => "JSON",
      "X-PAYPAL-APPLICATION-ID" => "APP-80W284485P519543T"
      
    }

    resp, data = http.post(path, data, headers)
    puts "PAYPAL SUCCESS"

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
