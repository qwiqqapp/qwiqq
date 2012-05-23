class CouponsController < ApplicationController
  before_filter :find_deal
  attr_reader :deal, :redeemed

  def show
    @redeemed = deal.redeem_coupon!
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
