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
  
  def test_paypal
    puts "PAYPAL TESTED IN COUPON"
    user = User.find_by_email("michaelscaria26@gmail.com")
    deal = Deal.find("10345")
    Mailer.category_test(user, deal).deliver
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
