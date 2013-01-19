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
    
  uri = URI.parse("https://auth.api.rackspacecloud.com")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Post.new("/v1.1/auth")
request.add_field('Content-Type', 'application/json')
request.body = {'credentials' => {'username' => 'username', 'key' => 'key'}}
response = http.request(request)
    puts "PAYPAL SUCCESS RESPONSE: #{res}"

  end
  
  def build_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.port == 443)
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http
  end

  def headers
    {
      "X-PAYPAL-SECURITY-USERID" => "caller_1312486258_biz_api1.gmail.com",
      "X-PAYPAL-SECURITY-PASSWORD" => "1312486294",
      "X-PAYPAL-SECURITY-SIGNATURE" => "AbtI7HV1xB428VygBUcIhARzxch4AL65.T18CTeylixNNxDZUu0iO87e",
      "X-PAYPAL-APPLICATION-ID" => "APP-80W284485P519543T",
      "X-PAYPAL-REQUEST-DATA-FORMAT" => "JSON",
      "X-PAYPAL-RESPONSE-DATA-FORMAT" => "JSON"
    }
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
