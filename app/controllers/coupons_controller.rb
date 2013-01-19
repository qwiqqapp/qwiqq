require "net/http"
require "uri"
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
    @result = HTTParty.post('https://svcs.sandbox.paypal.com/AdaptivePayments/Pay', :body => {:actionType => "PAY", :currencyCode => "USD", "receiverList.receiver(0).amount" => "1.00", "receiverList.receiver(0).email" => "rec1_1312486368_biz@gmail.com", :returnUrl => "www.yahoo.com", :cancelUrl => "gizmodo.com", :requestEnvelope => {:errorLanguage => "en_US", :detailLevel => "ReturnAll"}, :headers => {"X-PAYPAL-SECURITY-USERID" => "caller_1312486258_biz_api1.gmail.com", "X-PAYPAL-SECURITY-PASSWORD" => "1312486294", "X-PAYPAL-SECURITY-SIGNATURE" => "AbtI7HV1xB428VygBUcIhARzxch4AL65.T18CTeylixNNxDZUu0iO87e","X-PAYPAL-APPLICATION-ID" => "APP-80W284485P519543T","X-PAYPAL-REQUEST-DATA-FORMAT" => "JSON", "X-PAYPAL-RESPONSE-DATA-FORMAT" => "JSON"})
    puts "RESULT OF POST:#{@result}"
    
    redirect_to "www.google.com"
#{\\":\"PAY\", \"\":\"USD\", \"\":{\"receiver\":[{\"amount\":\"1.00\",\"email\":\"\"}]}, 
#\"\":\"http://www.example.com/success.html\", 
#cancelUrl\":\"http://www.example.com/failure.html\", \"\":{\"\":\"en_US\", \"\":\"\"}}"
  end

  def test
    
    uri = URI.parse("http://google.com/")
    http = Net::HTTP.new(uri.host, uri.port)
    credentials = {
        'USER' => 'payer_1342623102_biz_api1.gmail.com',
       'PWD' => '1342623141',
       'SIGNATURE' => 'Ay2zwWYEoiRoHTTVv365EK8U1lNzAESedJw09MPnj0SEIENMKd6jvnKL '
     }

    header =      {
      "X-PAYPAL-SECURITY-USERID" => "caller_1312486258_biz_api1.gmail.com",
      "X-PAYPAL-SECURITY-PASSWORD" => "1312486294",
      "X-PAYPAL-SECURITY-SIGNATURE" => "AbtI7HV1xB428VygBUcIhARzxch4AL65.T18CTeylixNNxDZUu0iO87e",
      "X-PAYPAL-APPLICATION-ID" => "APP-80W284485P519543T",
      "X-PAYPAL-REQUEST-DATA-FORMAT" => "JSON",
      "X-PAYPAL-RESPONSE-DATA-FORMAT" => "JSON"
    }
    data = {"actionType" => "PAY",
               "receiverList.receiver(0).email"=> 'mscaria@novationmobile.com',
               "receiverList.receiver(0).amount" => "1",
               "currencyCode" => "USD",
               "cancelUrl" => "http://www.google.com/",
               "returnUrl" => "http://www.yahoo.com/",          
               "requestEnvelope.errorLanguage" => "en_US",
               "ipnNotificationUrl" => "http://api.qwiqq.me//api/deals/10463/transactions?buyer_id=13527&sandbox=false"
               }
    puts "Just before posting"
    res = http.post(uri, data, header)
    puts "PAYPAL SUCCESS RESPONSE: #{res}"
    
        if pay_response.success?
      redirect_to pay_response.approve_paypal_payment_url
    else
      puts pay_response.errors.first['message']
      redirect_to failed_payment_url
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
