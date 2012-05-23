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
      unless deal.present? and deal.has_coupon?
        redirect_to root_url and return
      end
      deal
    end
  end
end
